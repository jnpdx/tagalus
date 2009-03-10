//Allows interaction with the Tagalus API
//See documentation at http://blog.tagal.us/api-documentation

//Requires jQuery OR you can redefine ajax_call and encode_params to use the JavaScript library of your choice

//NOTE: the format for all calls through this object must be .json

var TagalusAPI = {
  
  api_version : '0001', //this is set to the latest version by default - to use an older API version, you must redefine this
  api_server : 'http://api.tagal.us/', //only should be changed in the event of testing
  api_key : '', //if you set an API key here, it will be tied to every call.  Alternatively, you can specificy api_key in the params of api_call
  
  /********************/
  
  //Example: TagalusAPI.show_tag('sxsw',function(data) { alert(data.definition.the_definition })
  show_tag : function(the_tag,callback) {
    this.api_call('tag/' + the_tag + '/show.json',{}, function(data) {
      callback.call(this,data)
    });
  },
  
  //Example TagalusAPI.api_key = 'MYAPIKEY'; TagalusAPI.create_definition('sxsw','my definition for sxsw',function(data) { if (data.error == undefined) { alert("success!"); } })
  create_definition : function(tag,definition,callback) {
    if (this.api_key == '') {
      return 'NO_API_KEY';
    }
    this.api_call('definition/create.json',
    {
      the_tag: tag,
      the_definition: definition
    },
    function(data) {
      callback.call(this,data)
    })
  },
  
  /********************/
  
  
  
  api_key_param : function(k) {
    if (this.api_key == '') {
      return '';
    } else {
      return '&api_key=' + this.api_key;
    }
  },
  
  //example: TagalusAPI.api_call('tag/sxsw/show.json',{},function(data) { alert(data.definition.the_definition) })
  //example: TagalusAPI.api_key = "MYAPIKEY"; TagalusAPI.api_call('tag/create.json',{ the_tag: 'mytag', the_defintion: 'my definition'})
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
