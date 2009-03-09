//Allows interaction with the Tagalus API
//See documentation at http://blog.tagal.us/api-documentation

//Requires jQuery OR you can redefine ajax_call and encode_params to use the JavaScript library of your choice

var TagalusAPI = {
  
  api_version : '0001',
  api_server : 'http://api.tagal.us/',
  api_key : '',
  
  api_key_param : function(k) {
    if (this.api_key == '') {
      return '';
    } else {
      return '&api_key=' + this.api_key;
    }
  },
  
  api_call : function(req_uri, params, callback) {
    
    this.ajax_call( this.api_server + req_uri + '?' + this.encode_params(params) + this.api_key_param() + '&api_version=' + this.api_version + '&callback=?',callback);
    
  },
  
  ajax_call : function(url,callback) {
    
    if (window.jQuery != undefined) {
      jQuery.getJSON(url,callback);
    } else {
      log("jQuery is not available.  Either redefine TagalusAPI.ajax_call to use your library of choice, or install jQuery");
    }
    
  },
  
  encode_params : function(params) {
    
    if (window.jQuery != undefined) {
      return jQuery.param(params);
    } else {
      log("jQuery is not available.  Either redefine TagalusAPI.encode_params to use your library of choice, or install jQuery");
    }
    
  },
  
}

window.TagalusAPI = TagalusAPI;
