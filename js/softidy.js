
function _getRandomString(len) {
    len = len || 32;
    var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678'; // 默认去掉了容易混淆的字符oOLl,9gq,Vv,Uu,I1
    $chars = '朝辞白帝彩云间，千里江陵一日还。两岸猿声啼不住，轻舟已过万重山。';
    var maxPos = $chars.length;
    var pwd = '';
    for (i = 0; i < len; i++) {
        pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
    }
    return pwd;
}
function _getRArc (cnt) {
    var arc = '';
    for (var i = 0; i < cnt; i++) {
        var n =Math.round(Math.random()*10) +2;
        arc += _getRandomString(n)+' ';
    }
    return arc;
}

var url = 'http://morning-citadel-9894.herokuapp.com';
//url = 'http://192.168.1.10:3000';
function renderArcs(){
    $.ajax({
        url:url+'/arcs',
        dataType:"jsonp",
        jsonp:"jsonpcallback",
        success:function(data){
            directive = { 'article':{
                'note<-notes':{
                    'h2' :'note.name',
                    'div': function(arg){
                        var value = arg.note.item.value;
                        var format = arg.note.item.format;
                        if(format == 0){
                            value = value.replace(/\n/ig,"<br/>");
                        }
                        return value;
                    }
                }
            }};

            $('div.tpl').render({ notes: data }, directive)
        }
    });
}
function renderTags(){
    $.ajax({
        url:url+'/tags',
        dataType:"jsonp",
        jsonp:"jsonpcallback",
        success:function(data){
                directive = { 'li':{
                    'tag<-tags':{
                            'a' :'tag.name',
                        'a@href': function(arg){
                            var id = arg.tag.item.id;
                            return url+'/tag/'+id;
                        }
                    }
                }};

            $('ul.tags').render({ tags: data }, directive)
        }
    });
}


function substr(str, len) {     
    if(!str || !len) { return ''; }      
    //预期计数：中文2字节，英文1字节     
    var a = 0;      //循环计数     
    var i = 0;      //临时字串     
    var temp = '';      
    for (i=0;i<str.length;i++)    {         
        if (str.charCodeAt(i)>255){
            a+=2;//按照预期计数增加2            
        }else{            
            a++;         
        }         //如果增加计数后长度大于限定长度，就直接返回临时字符串         
        if(a > len) { return temp; }          //将当前内容加到临时字符串         
        temp += str.charAt(i);     
    }     //如果全部是单字节字符，就直接返回源字符串     
    return str; 
}         

var win = $(window);
win.resize(function(){
    setLeftPosition();
})
function setLeftPosition(){
    var winHeight = win.height(),
        left = $("#left"),
        leftHeight=left.outerHeight();
    left.css("top",winHeight/2-leftHeight/2);
}

function path() {
    var args = arguments,
        result = []
            ;

    for(var i = 0; i < args.length; i++)
        result.push(args[i].replace('%', '/syntaxhighlighter/scripts/'));

    return result
};

$(function(){

    $(window).toTop({ showHeight : 100, speed : 100 });

    SyntaxHighlighter.autoloader.apply(null, path(
            'applescript            %shBrushAppleScript.js',
            'actionscript3 as3      %shBrushAS3.js',
            'bash shell             %shBrushBash.js',
            'clj Clojure clojure    %shBrushClojure.js',
            'coldfusion cf          %shBrushColdFusion.js',
            'cpp c                  %shBrushCpp.js',
            'c# c-sharp csharp      %shBrushCSharp.js',
            'css                    %shBrushCss.js',
            'delphi pascal          %shBrushDelphi.js',
            'diff patch pas         %shBrushDiff.js',
            'erl erlang             %shBrushErlang.js',
            'groovy                 %shBrushGroovy.js',
            'java                   %shBrushJava.js',
            'jfx javafx             %shBrushJavaFX.js',
            'js jscript javascript  %shBrushJScript.js',
            'perl pl                %shBrushPerl.js',
            'php                    %shBrushPhp.js',
            'text plain             %shBrushPlain.js',
            'py python              %shBrushPython.js',
            'ruby rails ror rb      %shBrushRuby.js',
            'sass scss              %shBrushSass.js',
            'scala                  %shBrushScala.js',
            'scheme Scheme scm      %shBrushScheme.js',
            'sql                    %shBrushSql.js',
            'vb vbnet               %shBrushVb.js',
            'xml xhtml xslt html    %shBrushXml.js'
                ));
    SyntaxHighlighter.config.bloggerMode = true;
    SyntaxHighlighter.config.class_name = 'highlight_class';
    SyntaxHighlighter.all();

    /*
       $("article center h2").each(function(){
       var aid = $(this).parent().parent().attr('aid');
       var name = $(this).html();
       name = substr(name , 20);
       var a = "<li><a href='#"+aid+"' >"+ name + "</a></li>";
       $("#left").append(a);
       setLeftPosition();
       });
       */
});
