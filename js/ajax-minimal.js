/*
   http://spencerchristensen.com/blog/2007/11/minimal-ajax-toolkit.html

   Simple AJAX file that only provides the simplest features for fetching
   a url so you can do something with the contents.

      var am = new AJAXMinimal();
      am.fetch_url(request_method, url, argument_array, user_callback);

   An AJAXMinimal object has the following properties:
      am.content    // string value of the request's content
      am.url_loaded // boolean stating if the url loaded ok
      am.request    // the HTTP request object used to make requests
      am.url        // the url requested

   The argument_array needs to be an associative array with name value
   pairs.  These are URL encoded automatically when constructing the
   request.

   To fetch a url, you need to create a function that you pass in as the
   last argument to am.fetch_url().  This function will be passed one
   argument, the am object.  Within this callback, you are then able to
   do whatever you want with the returned content.

*/

function AJAXMinimal() {
    this.request = null;
    try {
      this.request = new XMLHttpRequest();
    } catch (trymicrosoft) {
      try {
        this.request = new ActiveXObject("Msxml2.XMLHTTP");
      } catch (othermicrosoft) {
        try {
          this.request = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (failed) {
          this.request = null;
        }
      }
    }
    if (null == this.request)
      alert("Error creating request object!");

    this.url = '';
    this.content = '';
    this.url_loaded = false;
}

AJAXMinimal.prototype.request = 'HTTP request object';
AJAXMinimal.prototype.url = 'Requested URL';
AJAXMinimal.prototype.content = 'Returned content of URL';
AJAXMinimal.prototype.url_loaded = 'Boolean if the url is loaded';

AJAXMinimal.prototype._build_arg_data = function (arr) {
    var arg_data = '';
    if (! arr) arr = new Array();
//    alert('_build_arg_data, arr.length='+ arr.length);
//    if (arr.length) {
        for (k in arr) {
//           alert('building arg_data, k = '+ k +', v='+ arr[k]);
            if (arg_data.length > 1) {
                arg_data += '&'+ escape(k) + '=' + escape(arr[k]);
            }
            else {
                arg_data = escape(k) + '=' + escape(arr[k]);
            }
        }
//    }
    return arg_data;
};


var _tmp_am;
var _user_callback;
function _get_url_content () {
    if (4 == _tmp_am.request.readyState) {
        _tmp_am.url_loaded = true;
        if (200 == _tmp_am.request.status) {
            _tmp_am.content = _tmp_am.request.responseText;
            if (_user_callback) {
                _user_callback(_tmp_am);
            }
            return;
        } else {
            alert("Error! Req status is " + _tmp_am.request.status);
            var message = _tmp_am.request.getResponseHeader("Status");
            if ((null == message.length) || (message.length <= 0)) {
            } else {
              alert(message);
            }
        }
    }
};

AJAXMinimal.prototype.fetch_url = function (request_method, url, argument_array, callback) {
    var arg_data = this._build_arg_data(argument_array);
//    alert('arg_data = '+ arg_data);

    this.content = null;
    this.url_loaded = false;
    _tmp_am = this;
    _user_callback = callback;

    if (arg_data && request_method == 'GET') {
        if (url.indexOf('?') > 0) {
            url += '&' + arg_data;
        }
        else {
            url += '?' + arg_data;
        }
    }
    this.url = url;
//    alert('requesting URL: '+ url);

    this.request.open(request_method, this.url, true);
    this.request.onreadystatechange = _get_url_content;

    if (request_method == 'POST') {
        this.request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        this.request.send(arg_data);
    }
    else {
        this.request.send();
    }
};
