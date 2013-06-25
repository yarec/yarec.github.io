SyntaxHighlighter.brushes.Scheme = function()
{
        // Contributed by Travis Whitton

        var syntax = 'lambda if set! cond and or let letrec begin do delay quasiquote let-syntax letrec-syntax syntax-rules define-syntax define ';

        var fun = 'display procedure? apply map for-each force call-with-current-continuation values call-with-values dynamic-wind ';

        var funcs = syntax + fun
                    

        this.regexList = [
                { regex: new RegExp(';[^\]]+$', 'gm'),                           css: 'comments' },
		{ regex: SyntaxHighlighter.regexLib.multiLineDoubleQuotedString, css: 'string' },
                { regex: /\[|\]/g,                                               css: 'keyword' },
		{ regex: /'[a-z][A-Za-z0-9_]*/g,                                 css: 'color1' }, // symbols
		{ regex: /:[a-z][A-Za-z0-9_]*/g,                                 css: 'color2' }, // keywords
		{ regex: new RegExp(this.getKeywords(funcs), 'gmi'),             css: 'functions' }
            ];
 
	this.forHtmlScript(SyntaxHighlighter.regexLib.aspScriptTags);
}

SyntaxHighlighter.brushes.Scheme.prototype     = new SyntaxHighlighter.Highlighter(); 
SyntaxHighlighter.brushes.Scheme.aliases       = ['scheme', 'Scheme', 'scm'];
