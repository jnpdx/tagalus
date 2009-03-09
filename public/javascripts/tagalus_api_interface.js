//Allows interaction with the Tagalus API
//See documentation at http://blog.tagal.us/api-documentation

var TagalusAPI = {
  
  api_version : '0001',
  api_server : 'http://api.tagal.us/',
  
  api_call : function(req_type, req_uri, callback, post_params) {
    
    if (post_params != null) {
      post_data = post_params;
    } else {
      post_data = '';
    }
    
    this.ajax_call({
      type: req_type,
      url: this.api_server + req_uri,
      data: post_data,
      success: callback,
    })
    
  },
  
  ajax_call : function(options) {
    
    if (window.jQuery != undefined) {
      jQuery.ajax(options);
    } else {
      log("jQuery is not available.  Either redefine TagalusAPI.ajax_call to use your library of choice, or install jQuery");
    }
    
  },
  
}

window.TagalusAPI = TagalusAPI;
