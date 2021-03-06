(define call/cc call-with-current-continuation)
(define (list . x) x)
(define (not x) (if x #f #t))
(define (negative? x) (< x 0))
(define (positive? x) (> x 0))
(define (even? x) (= (remainder x 2) 0))
(define (odd? x) (not (even? x)))
(define (zero? x) (= x 0))
(define (abs x) (if (< x 0) (- x) x))
(define magnitude abs)
(define exact? integer?)
(define (inexact? x) (not (exact? x)))
(define (random x) (floor (* (rnd) x)))
;
(define (char-ci=?  x y) (char=?  (char-downcase x) (char-downcase y)))
(define (char-ci>?  x y) (char>?  (char-downcase x) (char-downcase y)))
(define (char-ci<?  x y) (char<?  (char-downcase x) (char-downcase y)))
(define (char-ci>=? x y) (char>=? (char-downcase x) (char-downcase y)))
(define (char-ci<=? x y) (char<=? (char-downcase x) (char-downcase y)))
(define (char-lower-case? x) (char=? x (char-downcase x)))
(define (char-upper-case? x) (char=? x (char-upcase x)))
(define (char-alphabetic? x) (if (char-ci>=? x #\a) (char-ci<=? x #\z) #f))
(define (char-numeric? x) (if (char>=? x #\0) (char<=? x #\9) #f))
(define (char-whitespace? x) (char<=? x #\space))
(define (string-ci=?  x y) (string=?  (string-downcase x) (string-downcase y)))
(define (string-ci>?  x y) (string>?  (string-downcase x) (string-downcase y)))
(define (string-ci<?  x y) (string<?  (string-downcase x) (string-downcase y)))
(define (string-ci>=? x y) (string>=? (string-downcase x) (string-downcase y)))
(define (string-ci<=? x y) (string<=? (string-downcase x) (string-downcase y)))
;
(define (map f ls . more)
  (define (map1 l)
    (if (null? l)
      '()
      (if (pair? l)
          (cons (f (car l)) (map1 (cdr l)))
          (f l))))
  (define (map-more l m)
    (if (null? l)
        '()
        (if (pair? l)
            (cons (apply f (car l) (map car m))
                  (map-more (cdr l)
                            (map cdr m)))
            (apply f l m))))
  (if (null? more)
      (map1 ls)
      (map-more ls more)))
; tail-recursive map
(define (map+ f . lst)
  (define r '())
  (define o #f)
  (define p #f)
  (define (map-lst op l)
    (if (pair? l) (cons (op (car l)) (map-lst op (cdr l))) '()))
  (define (do-map)
    (if (pair? (car lst)) (begin
          (set! o (cons (apply f (map car lst)) '()))
          (if (null? r) (set! r o) (set-cdr! p o))
          (set! p o)
          (set! lst (map cdr lst))
          (do-map))
      (if (not (null? (car lst)))
         (if p (set-cdr! p (apply f lst))
               (set! r (apply f lst))))))
  (do-map) r)
;
(define (caar x) (car (car x)))
(define (cadr x) (car (cdr x)))
(define (cdar x) (cdr (car x)))
(define (cddr x) (cdr (cdr x)))
;
(define (caaar x) (car (car (car x))))
(define (caadr x) (car (car (cdr x))))
(define (cadar x) (car (cdr (car x))))
(define (caddr x) (car (cdr (cdr x))))
(define (cdaar x) (cdr (car (car x))))
(define (cdadr x) (cdr (car (cdr x))))
(define (cddar x) (cdr (cdr (car x))))
(define (cdddr x) (cdr (cdr (cdr x))))
;
(define (caaddr x) (car (car (cdr (cdr x)))))
(define (cadddr x) (car (cdr (cdr (cdr x)))))
(define (cdaddr x) (cdr (car (cdr (cdr x)))))
(define (cddddr x) (cdr (cdr (cdr (cdr x)))))
;
(define (length lst . x)
  (define l (if (null? x) 0 (car x)))
  (if (pair? lst) (length (cdr lst) (+ l 1)) l))
(define (length+ lst . x)
  (define l (if (null? x) 0 (car x)))
  (if (null? lst) l
      (if (pair? lst) (length+ (cdr lst) (+ l 1)) (+ l 1))))

(define (list-ref lst n)
  (if (= n 0) (car lst) (list-ref (cdr lst) (- n 1))))
(define (list-tail lst n)
  (if (= n 0) lst (list-tail (cdr lst) (- n 1))))
(define (reverse lst . l2)
  (define r (if (null? l2) l2 (car l2)))
  (if (null? lst) r
      (reverse (cdr lst) (cons (car lst) r))))
;
(define (append l1 . more)
  (if (null? more) l1
    (begin
      (define l2 (car more))
      (define m2 (cdr more))
      (if (null? l1)
          (apply append l2 m2)
          (cons (car l1)
                (apply append (cdr l1) l2 m2))))))
;
(define sort #f)
(define merge #f)
((lambda ()
  (define dosort
    (lambda (pred? ls n)
      (if (= n 1) (list (car ls))
          (if (= n 2)
              (begin (define x (car ls)) (define y (cadr ls))
                     (if (pred? y x) (list y x) (list x y)))
              (begin (define i (quotient n 2))
                     (domerge pred?
                              (dosort pred? ls i)
                              (dosort pred? (list-tail ls i) (- n i))))))))
  (define domerge
    (lambda (pred? l1 l2)
      (if (null? l1)
          l2
          (if (null? l2)
              l1
              (if (pred? (car l2) (car l1))
                  (cons (car l2) (domerge pred? l1 (cdr l2)))
                  (cons (car l1) (domerge pred? (cdr l1) l2)))))))
  (set! sort
    (lambda (pred? l)
      (if (null? l) l (dosort pred? l (length l)))))
  (set! merge
    (lambda (pred? l1 l2)
      (domerge pred? l1 l2)))))
;
(define (iota count . x)
  (define start 0)
  (define step 1)
  (if (not (null? x)) (begin (set! start (car x))
  (if (not (null? (cdr x))) (begin (set! step (cadr x))))))
  (define (do-step cnt lst)
    (if (< cnt 0) lst
        (do-step (- cnt 1) (cons (+ (* step cnt) start) lst))))
  (do-step (- count 1) '()))
;
(define (list->string lst) (apply string lst))
;
(define (gcd a b) ; 2Do: (gcd) => 0
  (if (= b 0)
      a
      (gcd b (remainder a b))))
(define (lcm x y) (/ (* x y) (gcd x y))) ; 2Do: (lcm) => 1
;
(define (max x . l)
  (if (null? l) x
      (apply max (if (> x (car l)) x (car l)) (cdr l))))
(define (min x . l)
  (if (null? l) x
      (apply max (if (< x (car l)) x (car l)) (cdr l))))
;
(define syntax-quasiquote ((lambda ()
  (define (ql x)
    (if (pair? x)
        (if (null? x)
            ''()
            (if (eq? (car x) 'unquote)
                (cadr x)
                (if (if (pair? (car x))
                        (eq? (caar x) 'unquote-splicing)
                        #f)
                    (if (null? (cdr x))
                        (cadar x)
                        (list 'append (cadar x) (ql (cdr x))))
                    (if (null? (cdr x))
                        (list 'list (ql (car x)))
                        (list 'cons (ql (car x)) (ql (cdr x)))))))
        (if (symbol? x) (list 'quote x) x)))
  (lambda (expr)
  (ql (cadr expr))))))
(define-syntax quasiquote (syntax-quasiquote))
;
(define (f-and . lst)
  (if (null? lst) #t
      (if (car lst) (apply f-and (cdr lst)) #f)))
(define (f-or . lst)
  (if (null? lst) #f
      (if (car lst) #t (apply f-or (cdr lst)))))
;
(define (syntax-rules expr literals p1 . more)
  (define vars '())
  ;
  (define (match ex pat)
    (if (null? pat) (null? ex)
      (if (symbol? pat)
        (begin (set! vars (cons (cons pat ex) vars)) #t)
        (if (eq? (cadr pat) '...)
            (match-many ex (car pat))
            (if (if (null? ex) #f
                (if (memq+ (car pat) literals)
                    (eq? (car pat) (car ex))
                    (if (symbol? (car pat))
                        (begin
                           (set! vars (cons (cons (car pat) (car ex)) vars))
                           #t)
                        (if (if (pair? (car pat))
                                (if (null? (car ex)) #t (pair? (car ex)))
                                #f)
                            (match (car ex) (car pat))
                            (eqv? (car pat) (car ex)))))) ; equal?
                (match (cdr ex) (cdr pat))
                #f)))))
  ;
  (define (match-many ex pat)
    (if (null? ex) #t
        (if (match (list (car ex)) (list pat))
            (match-many (cdr ex) pat)
            #f)))
  ;
  (define (find-all var lst out)
    (if (null? lst)
        out
        (if (eq? var (caar lst))
            (find-all var (cdr lst) (cons (cdar lst) out))
            (find-all var (cdr lst) out))))
  ;
  (define (p-each lst templ)
    (if (null? lst)
        '()
        (cons (if (null? (car lst)) (car templ) (caar lst))
              (p-each (cdr lst) (cdr templ)))))
  ;
  (define (process-many lst templ)
    (define not-empty #f)
    (define (l2 l)
      (if (null? l)
          '()
          (begin
            (define a (car l))
            (if (not (null? a))
                (begin (set! not-empty #t) (set! a (cdr a))))
            (cons a (l2 (cdr l))))))
    (define ll (l2 lst))
    (if not-empty
        (cons (p-each lst templ)
              (process-many ll templ))
        '()))
  ;
  (define (gen-many templ)
    (if (null? templ)
        '()
        (if (pair? templ)
            (process-many (map+ gen-many templ) templ)
            (find-all templ vars '()))))
  ;
  (define (ren x)
    (define new #f)
    (if (eq? x '...)
        x
        (begin
          (set! new (gen-sym x))
          (set! vars (cons (cons x new) vars))
          new)))
  ; 2Do: generate temporary symbols in (define ...)
  (define (gen templ no...)
    (define old-vars #f)
    (define args #f)
    (define body #f)
    (define new #f)
    (define x #f)
    ;
    (if (null? templ)
        '()
        (if (pair? templ)
            (if (if no... (eq? (cadr templ) '...) #f)
                (append (gen-many (car templ))
                        (gen (cddr templ) no...))
                (if (if no... (eq? (car templ) 'lambda) #f)
                    (begin
                      (set! old-vars vars)
                      (set! args (gen (cadr templ) no...))
                      (set! body (gen (cddr templ) no...))
                      (set! vars '())
                      (set! new (map+ ren args))
                      (set! new
                        (cons (car templ)
                              (cons new
                                    (gen body #f))))
                      (set! vars old-vars)
                      new)
                    (cons (gen (car templ) no...) (gen (cdr templ) no...))))
            (begin
              (set! x (assq templ vars))
              (if x (cdr x) templ)))))
  ;
  (if (match (cdr expr) (cdar p1))
      (gen (cadr p1) #t)
      (if (null? more)
          (error (string-append "no pattern matches "
                                (symbol->string (car expr))))
          (apply syntax-rules expr literals more))))
;
(define-syntax and
  (syntax-rules ()
  ((_) #t)
  ((_ test) test)
  ((_ test1 test2 ...)
    (if test1 (and test2 ...) #f))))
;
(define-syntax or
  (syntax-rules ()
    ((_) #f)
    ((_ test) test)
    ((_ test1 test2 ...)
     (let ((_tmp_ test1))
       (if _tmp_ _tmp_ (or test2 ...))))))
;
(define-syntax let
  (syntax-rules ()
    ((_ ((name val) ...) body1 ...)
     ((lambda (name ...) body1 ...)
      val ...))
    ((_ tag ((name val) ...) body1 ...)
    ((letrec ((tag (lambda (name ...)
                     body1 ...))) tag)
      val ...))))
;
(define-syntax cond
  (syntax-rules (else =>)
    ((_ (else result1 ...))
     (begin result1 ...))
    ((_ (test => result))
     (let ((_tmp_ test))
       (if _tmp_ (result _tmp_))))
    ((_ (test => result) clause1 ...)
     (let ((_tmp_ test))
       (if _tmp_
           (result _tmp_)
           (cond clause1 ...))))
    ((_ (test)) test)
    ((_ (test) clause1 ...)
     (let ((_tmp_ test))
       (if _tmp_ _tmp_
           (cond clause1 ...))))
    ((_ (test result1 ...))
     (if test (begin result1 ...)))
    ((_ (test result1 ...)
           clause1 ...)
     (if test
         (begin result1 ...)
         (cond clause1 ...)))))
;
(define-syntax let*
  (syntax-rules ()
    ((_ () body1 ...)
     (begin body1 ...))
    ((_ ((name1 val1) (name2 val2) ...) body1 ...)
     ((lambda (name1) (let* ((name2 val2) ...) body1 ...)) val1))))
(define-syntax letrec
  (syntax-rules ()
    ((_ ((var1 init1) ...) body ...)
     ((lambda ()
       (define var1 #f) ...
       ((lambda _tmplst_
          (begin (set! var1 (car _tmplst_))
                 (set! _tmplst_ (cdr _tmplst_))) ...) init1 ...)
       body ...)))))
(define-syntax let-syntax
  (syntax-rules ()
    ((_ ((_var1_ _init1_) ...) _body_ ...)
     ((lambda () (define-syntax _var1_ _init1_) ... _body_ ...)))))
(define letrec-syntax let-syntax)
;
(define-syntax case
  (syntax-rules (else)
    ((_ (key ...)
       clauses ...)
     (let ((_tmp_ (key ...)))
       (case _tmp_ clauses ...)))
    ((_ key
       (else result1 ...))
     (begin result1 ...))
    ((_ key
       ((atoms ...) result1 ...))
     (if (memv key '(atoms ...))
         (begin result1 ...)))
    ((_ key
       ((atoms ...) result1 ...)
       clause ...)
     (if (memv key '(atoms ...))
         (begin result1 ...)
         (case key clause ...)))))
;
(define-syntax do
  (syntax-rules ()
    ((_ ((var init step) ...)
        (test expr ...)
        command ...)
     (letrec ; 2Do: simplify!
       ((_loop_
         (lambda (var ...)
           (if test
               (begin expr ...)
               (begin
                 command ...
                 (_loop_ (do "step" var step) ...))))))
       (_loop_ init ...)))
    ((_ "step" x) x)
    ((_ "step" x y) y)))
;
(define (memq+ x ls)
  (if (pair? ls)
      (if (eq? (car ls) x) ls
          (memq+ x (cdr ls)))
      (if (eq? x ls) ls #f)))
(define memq memq+)
(define (memv x ls)
  (if (pair? ls)
      (if (eqv? (car ls) x) ls
          (memv x (cdr ls)))
  (if (eqv? x ls) ls #f)))
(define (member x ls)
  (if (pair? ls)
      (if (equal? (car ls) x) ls
          (member x (cdr ls)))
  (if (equal? x ls) ls #f)))
;
(define (assq x ls)
  (if (null? ls) #f
      (if (eq? (caar ls) x) (car ls)
          (assq x (cdr ls)))))
(define (assv x ls)
  (if (null? ls) #f
      (if (eqv? (caar ls) x) (car ls)
          (assv x (cdr ls)))))
(define (assoc x ls)
  (if (null? ls) #f
      (if (equal? (caar ls) x) (car ls)
          (assoc x (cdr ls)))))
;
(define list?
  ((lambda ()
    (define (race h t)
      (if (pair? h)
          ((lambda (h)
             (if (pair? h)
                 (if (not (eq? h t))
                     (race (cdr h) (cdr t))
                     #f)
                 (null? h))) (cdr h))
          (null? h)))
    (lambda (x) (race x x)))))
;
(define equal?
  (lambda (x y)
    ((lambda (eqv)
       (if eqv eqv
           (if (pair? x)
               (begin
                 (if (pair? y)
                     (if (equal? (car x) (car y))
                         (equal? (cdr x) (cdr y))
                         #f)
                     #f))
                 (if (vector? x)
                     (if (vector? y)
                         ((lambda (n)
                            (if (= (vector-length y) n)
                                ((begin
                                   (define loop
                                     (lambda (i)
                                       ((lambda (eq-len)
                                          (if eq-len
                                              eq-len
                                              (if (equal? (vector-ref x i)
                                                          (vector-ref y i))
                                                  (loop (+ i 1))
                                                  #f)))
                                        (= i n))))
                                   loop)
                                 0)
                                #f))
                          (vector-length x))
                         #f)
                     #f))))
     (eqv? x y))))
(define (values . things)
  (call/cc
    (lambda (cont) (apply cont things))))
(define (call-with-values producer consumer)
  (consumer (producer)))
;
(define (for-each f . lst)
  (if (not (null? (car lst))) (begin
      (apply f (map+ car lst))
      (apply for-each f (map+ cdr lst)))))
;
(define-syntax delay
  (syntax-rules ()
    ((_ exp) (make-promise (lambda () exp)))))
(define (make-promise p)
  ((lambda ()
    (define val #f)
    (define set? #f)
    (lambda ()
      (if (not set?)
          (begin (define x (p))
            (if (not set?)
                (begin (set! val x)
                       (set! set? #t)))))
      val))))
(define (force promise) (promise))
;
(define (string-copy x) x)
(define (vector-fill! v obj)
  (define l (vector-length v))
  (define (vf i) (if (< i l) (begin (vector-set! v i obj) (vf (+ i 1)))))
  (vf 0))
(define (vector->list v)
  (define (loop i l)
    (if (< i 0)
        l
        (loop (- i 1) (cons (vector-ref v i) l))))
  (loop (- (vector-length v) 1) '()))
(define (list->vector l)
  (define v (make-vector 0)) ; js :)
  (define (loop i l)
    (if (pair? l)
        (begin (vector-set! v i (car l))
               (loop (+ i 1) (cdr l)))
        (if (not (null? l)) (vector-set! v i l))))
  (loop 0 l) v)
;
(define dynamic-wind #f)
((lambda ()

  (define winders '())

  (define (common-tail x y)
     (define lx (length x))
     (define ly (length y))
     (define (loop x y)
       (if (eq? x y)
           x
           (loop (cdr x) (cdr y))))
     (loop (if (> lx ly) (list-tail x (- lx ly)) x)
           (if (> ly lx) (list-tail y (- ly lx)) y)))

  (define (do-wind new)
    (define tail (common-tail new winders))
    (define (f1 l)
      (if (not (eq? l tail))
          (begin
            (set! winders (cdr l))
            ((cdar l))
            (f1 (cdr l)))))
    (define (f2 l)
      (if (not (eq? l tail))
          (begin
            (f2 (cdr l))
            ((caar l))
            (set! winders l))))
    (f1 winders)
    (f2 new))

  ((lambda (c)
    (set! call/cc
      (lambda (f)
        (c (lambda (k)
             (f ((lambda (save)
                  (lambda x
                    (if (not (eq? save winders)) (do-wind save))
                    (apply k x)))
                 winders)))))))
      call/cc)
  (set! call-with-current-continuation call/cc)

  (set! dynamic-wind
    (lambda (in body out)
      (define ans #f)
      (in)
      (set! winders (cons (cons in out) winders))
      (set! ans (body))
      (set! winders (cdr winders))
      (out)
      ans))))
;
(define (js-char c)
  (define char-code (char->integer c))
  (if (>= char-code 32) (string c)
      (string-append "\\x" (if (< char-code 16) "0" "")
                     (number->string char-code 16))))

(define (compile ex . tt)
  (define tail #f)
  (define locs #f)
  (define app "Apply")
  (define prefix "")
  (define suffix "")

  (if (not (null? tt))
    (begin (set! locs (car tt))
      (if (not (null? (cdr tt)))
        (begin (set! tail (cadr tt))
          (if (not (null? (cddr tt)))
            (begin (set! prefix (caddr tt))
                   (set! suffix (cadddr tt))))))))
  (if tail (set! app "TC"))

  (if (number? ex) (string-append prefix (number->string ex) suffix)
  (if (symbol? ex)
      (if locs
          (string-append prefix (locs 'gen ex "e") suffix)
         ; (string-append prefix "e['" (symbol->string ex) "']" suffix)
          (string-append prefix "e.get('" (symbol->string ex) "')" suffix))
  (if (string? ex) (string-append prefix (str ex) suffix)
  (if (char? ex) (string-append prefix "getChar('" (js-char ex) "')" suffix)
  (if (null? ex) (error "cannot compile ()")
  (if (boolean? ex) (string-append prefix (if ex "true" "false") suffix)
  (if (vector? ex)
      (string-append prefix app "(e.get('list->vector'),"
                     (if tail "list=" "") "new Pair("
                     (compile-quote (vector->list ex)) ",theNil),e)" suffix)
  (if (not (pair? ex)) (error (string-append "cannot compile " (str ex)))
  ;
  (compile-pair ex locs tail prefix suffix app))))))))))

(define (compile-pair ex locs tail prefix suffix app)
  (define list-len (if (pair? locs) (length locs) #f))

  (if (eq? (car ex) 'begin)  (compile-begin (cdr ex) locs tail prefix suffix)
  (if (eq? (car ex) 'quote)  (compile-quote (cadr ex) prefix suffix)
  (if (eq? (car ex) 'not)
      (compile (cadr ex) locs #f (string-append prefix "(") (string-append "==false)" suffix))
  (if (eq? (car ex) 'symbol->string)
      (compile (cadr ex) locs #f prefix (string-append suffix ".name"))
  (if (eq? (car ex) 'car)    (string-append prefix (compile (cadr ex) locs) ".car" suffix)
  (if (eq? (car ex) 'cdr)    (string-append prefix (compile (cadr ex) locs) ".cdr" suffix)
  (if (eq? (car ex) 'caar)   (string-append prefix (compile (cadr ex) locs) ".car.car" suffix)
  (if (eq? (car ex) 'cadr)   (string-append prefix (compile (cadr ex) locs) ".cdr.car" suffix)
  (if (eq? (car ex) 'cdar)   (string-append prefix (compile (cadr ex) locs) ".car.cdr" suffix)
  (if (eq? (car ex) 'cddr)   (string-append prefix (compile (cadr ex) locs) ".cdr.cdr" suffix)
  (if (eq? (car ex) 'caaar)  (string-append prefix (compile (cadr ex) locs) ".car.car.car" suffix)
  (if (eq? (car ex) 'caddr)  (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.car" suffix)
  (if (eq? (car ex) 'cdaar)  (string-append prefix (compile (cadr ex) locs) ".car.car.cdr" suffix)
  (if (eq? (car ex) 'cdddr)  (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.cdr" suffix)
  (if (eq? (car ex) 'caaddr) (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.car.car" suffix)
  (if (eq? (car ex) 'cadddr) (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.cdr.car" suffix)
  (if (eq? (car ex) 'cdaddr) (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.car.cdr" suffix)
  (if (eq? (car ex) 'cddddr) (string-append prefix (compile (cadr ex) locs) ".cdr.cdr.cdr.cdr" suffix)
  (if (eq? (car ex) 'cons)
      (string-append prefix "new Pair(" (compile (cadr ex) locs)
                     "," (compile (caddr ex) locs) ")" suffix)
  (if (eq? (car ex) 'boolean?) (string-append prefix "(typeof(" (compile (cadr ex) locs) ")=='boolean')" suffix)
  (if (eq? (car ex) 'string?)  (string-append prefix "(typeof(" (compile (cadr ex) locs) ")=='string')" suffix)
  (if (eq? (car ex) 'number?)  (string-append prefix "(typeof(" (compile (cadr ex) locs) ")=='number')" suffix)
  (if (eq? (car ex) 'char?)    (string-append prefix "((" (compile (cadr ex) locs) ")instanceof Char)" suffix)
  (if (eq? (car ex) 'symbol?)  (string-append prefix "((" (compile (cadr ex) locs) ")instanceof Symbol)" suffix)
  (if (eq? (car ex) 'syntax?)  (string-append prefix "((" (compile (cadr ex) locs) ")instanceof Syntax)" suffix)
  (if (eq? (car ex) 'null?)    (string-append prefix "(" (compile (cadr ex) locs) "==theNil)" suffix)
  (if (eq? (car ex) 'pair?)    (string-append prefix "((" (compile (cadr ex) locs) ")instanceof Pair)" suffix)
  (if (eq? (car ex) 'str)      (string-append prefix "Str(" (compile (cadr ex) locs) ")" suffix)
  (if (eq? (car ex) 'clone)    (string-append prefix (compile (cadr ex) locs) ".clone(e)" suffix)
  (if (eq? (car ex) 'get-prop) (string-append prefix (compile (cadr ex) locs) "[" (str (caddr ex)) "]" suffix)
  (if (if (eq? (car ex) '>) #t (if (eq? (car ex) '<) #t
      (if (eq? (car ex) '>=) #t (eq? (car ex) '<=))))
      (string-append prefix 
        (compile-predicate (symbol->string (car ex)) (cdr ex) locs)
        suffix)
  (if (eq? (car ex) '+)        (string-append prefix (compile-append "0" "+" (cdr ex) locs) suffix)
  (if (eq? (car ex) '*)        (string-append prefix (compile-append "1" "*" (cdr ex) locs) suffix)
  (if (eq? (car ex) '-)        (string-append prefix (compile-minus "-" "-" (cdr ex) locs) suffix)
  (if (eq? (car ex) '/)        (string-append prefix (compile-minus "1/" "/" (cdr ex) locs) suffix)
  (if (eq? (car ex) 'string-append)
      (string-append prefix (compile-append "''" "+" (cdr ex) locs) suffix)
  (if (if (eq? (car ex) 'eq?) #t
        (if (eq? (car ex) '=) #t
        (if (eq? (car ex) 'eqv?) #t
        (if (eq? (car ex) 'string=?) #t (eq? (car ex) 'char=?)))))
      (string-append prefix "isEq(" (compile (cadr ex) locs) "," (compile (caddr ex) locs) ")" suffix)
  (if (eq? (car ex) 'list) (string-append prefix (compile-list (cdr ex) locs) suffix)
  (if (eq? (car ex) 'if)
;      (string-append prefix "(" (compile (cadr ex) locs)
;                     "!=false?" (compile (caddr ex) locs tail)
;                     ":" (if (null? (cdddr ex)) "null"
;                             (compile (cadddr ex) locs tail)) ")" suffix)
      (if (null? (cdddr ex))
          (compile (caddr ex) locs tail
                   (string-append prefix "((" (compile (cadr ex) locs) ")!=false?")
                   (string-append ":null)" suffix))
          (compile (cadddr ex) locs tail
                   (string-append prefix "((" (compile (cadr ex) locs)
                                  ")!=false?" (compile (caddr ex) locs tail) ":")
                   (string-append ")" suffix)))
  (if (eq? (car ex) 'define-syntax)
      (string-append prefix "e['" (symbol->string (cadr ex))
                     "']=new Syntax(e.get('" (symbol->string (caaddr ex))
                     "')," (compile-quote (cdaddr ex)) ")" suffix)
  (if (if (eq? (car ex) 'define) (symbol? (cadr ex)) #f)
      (begin (if locs (locs 'add (cadr ex)))
      (string-append prefix "e['" (symbol->string (cadr ex))
                     "']=" (compile (caddr ex) locs) suffix))
  (if (eq? (car ex) 'set!)
      (if (if locs (locs 'memq (cadr ex)) #f)
          (compile (caddr ex) locs #f
            (string-append prefix "e['" (symbol->string (cadr ex)) "']=")
            suffix)
          (compile (caddr ex) locs #f
            (string-append prefix "e.set('" (symbol->string (cadr ex)) "',")
            (string-append ")" suffix)))
  (if (eq? (car ex) 'lambda)
      (string-append prefix (compile-lambda-obj (cadr ex) (cddr ex) locs) suffix)
  (if (if (eq? (car ex) 'define) (pair? (cadr ex)) #f)
      (begin (if locs (locs 'add (caadr ex)))
      (string-append prefix "e['" (symbol->string (caadr ex))
                     "']=" (compile-lambda-obj (cdadr ex) (cddr ex) locs) suffix))
  (if (eq? (car ex) 'apply)
      (string-append prefix app "(" (compile (cadr ex) locs)
                     "," (if tail "list=" "")
                     (compile-apply-list (cddr ex) locs) ")" suffix)
  ; else function call
  (if (if tail (if (number? list-len) (>= list-len (length (cdr ex))) #f) #f)
    (string-append prefix "(" (compile-reuse (cdr ex) "list" locs) ","
                   "theTC.f=" (compile (car ex) locs) ",theTC.args=list,theTC)" suffix)
                  ; app "(" (compile (car ex) locs) ",list))" suffix)
    (compile-list (cdr ex) locs
      (string-append prefix app "(" (compile (car ex) locs) "," (if tail "list=" ""))
      (string-append ")" suffix)) 
; direct call attempts, not via Apply...
; (if tail "" "f.compiled?f.compiled(l):")
; (if tail "" "f.FType==1?f(l):")
)))))))))))))))))))))))))))))))))))))))))))))))

(define (compile-reuse lst var locs)
  (if (pair? lst)
      (string-append "(" var ".car=" (compile (car lst) locs) "),"
                     (compile-reuse (cdr lst) (string-append var ".cdr") locs))
      (string-append "(" var "=" (if (null? lst) "theNil" (compile lst locs)) ")")))

(define (compile-predicate op lst locs)
  (define s (string-append (compile (car lst) locs) op (compile (cadr lst) locs)))
  (if (null? (cddr lst)) s (string-append s "&&" (compile-predicate op (cdr lst) locs))))

(define (compile-minus one op lst locs)
  (if (null? (cdr lst))
      (string-append "(" one (compile (car lst) locs) ")")
      (compile-append "0" op lst locs)))

(define (compile-append zero op lst locs . q)
  (if (null? lst) zero
    (if (null? (cdr lst)) (compile (car lst) locs)
      (string-append (if (null? q) "(" "")
                     (compile (car lst) locs) op
                     (compile-append zero op (cdr lst) locs #t)
                     (if (null? q) ")" "")))))

(define (compile-list ex locs . tt)
  (define prefix "")
  (define suffix "")
  (if (not (null? tt))
    (begin (set! prefix (car tt))
           (set! suffix (cadr tt))))

  (if (null? ex) (string-append prefix "theNil" suffix)
  (if (pair? ex)
;      (string-append "new Pair(" (compile (car ex) locs)
;                     "," (compile-list (cdr ex) locs) ")")
      (compile-list (cdr ex) locs
        (string-append prefix "new Pair(" (compile (car ex) locs) ",")
        (string-append ")" suffix))
      (compile ex locs #f prefix suffix))))

(define (compile-quote ex . tt)
  (define prefix "")
  (define suffix "")
  (if (not (null? tt))
      (begin (set! prefix (car tt)) (set! suffix (cadr tt))))
  (if (null? ex) (string-append prefix "theNil" suffix)
  (if (symbol? ex)
      (string-append prefix "getSymbol('" (symbol->string ex) "')" suffix)
  (if (pair? ex)
      (compile-quote (cdr ex)
        (string-append prefix "new Pair(" (compile-quote (car ex)) ",")
        (string-append ")" suffix))
      (compile ex #f #f prefix suffix)))))

(define (compile-begin ex locs tail prefix suffix . q)
  (if (null? ex) (string-append prefix "null" suffix)
  (if (null? (cdr ex)) (compile (car ex) locs tail prefix suffix)
  (compile-begin (cdr ex) locs tail
    (string-append prefix (if (null? q) "(" "") (compile (car ex) locs) ",")
    (string-append (if (null? q) ")" "") suffix) #t))))

(define (compile-apply-list lst locs)
  (if (null? (cdr lst))
      (compile (car lst) locs #f "" ".ListCopy()")
      (string-append "new Pair(" (compile (car lst) locs)
                     "," (compile-apply-list (cdr lst) locs) ")")))

(define (compile-lambda-args args var)
  (if (null? args) ""
  (if (symbol? args)
      (string-append "e['" (symbol->string args) "']=" var ";")
      (string-append "e['" (symbol->string (car args))
                     "']=" var ".car;"
                     (compile-lambda-args (cdr args) (string-append var ".cdr"))))))

(define (compile-extract-children obj . c)
  (define tmp-name #f)
  (define a #f)
  (define d #f)
  (if (if (pair? obj) (not (eq? (car obj) 'quote)) #f)
      (if (eq? (car obj) 'lambda)
          (begin
            (set! tmp-name (gen-sym))
            (cons (list 'clone tmp-name)
                  (cons (cons tmp-name (cdr obj)) c)))
          (if (if (eq? (car obj) 'define) (pair? (cadr obj)) #f)
              (begin
                (set! tmp-name (gen-sym))
                (cons (list 'define (caadr obj) (list 'clone tmp-name))
                      (cons (cons tmp-name (cons (cdadr obj) (cddr obj))) c)))
              (begin
                (set! a (compile-extract-children (car obj)))
                (set! d (compile-extract-children (cdr obj)))
                (cons (cons (car a) (car d))
                      (append (cdr a) (cdr d))))))
      (cons obj c)))

(define (compile-lambda-obj args body . tt)
  (define parent-locs (if (null? tt) #f (car tt)))
  (define ex (compile-extract-children body))
  (define ll #f)
  (set! body (car ex))
  (if (not (null? (cdr ex)))
      (set! parent-locs (compile-make-locals (map+ car (cdr ex)) parent-locs)))
  (set! parent-locs (compile-make-locals args parent-locs))
  (set! ll (compile-lambda args body parent-locs))
  (string-append "new Lambda(" (compile-quote args)
    "," (if (null? (cdr body))
            (compile-quote (car body))
            (compile-quote (cons 'begin body)))
    "," (if (null? (cdr ex)) "e"
    (apply string-append "new Env(e)" (map+
           (lambda (l) (string-append
             ".With('" (symbol->string (car l)) "',"
             (compile-lambda-obj (cadr l) (cddr l) parent-locs) ")"))
        (cdr ex))))
    "," ll ")"))

(define (compile-make-locals lst parent)
  (lambda (msg v . tt)
    (define e (if (null? tt) "e" (car tt)))
    (if (eq? msg 'set!)
        (set! lst v)
      (if (eq? msg 'get)
          lst
        (if (eq? msg 'add)
            (set! lst (cons v lst))
          (if (eq? msg 'memq)
              (memq v lst)
            (if (eq? msg 'gen)
                (if (memq v lst)
                    (string-append e "['" (symbol->string v) "']")
                  (if parent
                      (parent 'gen v (string-append e ".parentEnv"))
                      (string-append "TopEnv.get('" (symbol->string v) "')"))))))))))

(define (compile-lambda args body locs)
  (compile-begin body locs #t
    (string-append "function(list){var r,e=new Env(this.env);while(true){"
                   (compile-lambda-args args "list") "r=")
    (string-append ";if(r!=theTC||r.f!=this)return r}}")))
;
(define (eval-compiled s)
  (js-eval (string-append "var e=TopEnv;" s)))
(define (compiled s)
  (js-invoke (get-prop s "compiled") "toString"))
(define (compile-lib s)
  (define lib (parse s))
  (define (print x) (display x)(display #\;)(newline))
  (print "var e=TopEnv")
  (define (print-compiled x) (print (compile x)))
  (for-each print-compiled lib))
;
(define (server x)
  (js-invoke (js-eval "window.frames.hf") "navigate"
    (string-append "servlet/db?s=" (encode (str x)))))
;
(define (transform ex)
  (if (pair? ex)
      (if (symbol? (car ex))
          (if (eq? (car ex) 'quote)
            ex
            (if (if (eq? (car ex) 'begin)
                    (if (null? (cdr ex)) #f (null? (cddr ex))) #f)
              (transform (cadr ex))
              (if (if (eq? (car ex) 'lambda) #t
                      (if (eq? (car ex) 'define) #t
                          (eq? (car ex) 'set!)))
                  (cons (car ex) (cons (cadr ex) (map+ transform (cddr ex))))
                  (begin
                    (define x (eval (car ex)))
                    (if (syntax? x)
                        (transform (apply (get-prop x "transformer") ex (get-prop x "args")))
                        (cons (car ex) (map+ transform (cdr ex))))))))
          (map+ transform ex))
      ex))
