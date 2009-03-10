//Allows interaction with the Tagalus API
//See documentation at http://blog.tagal.us/api-documentation
//Questions/comments: tagalus+api@gmail.com

//Requires jQuery OR you can redefine ajax_call and encode_params to use the JavaScript library of your choice

//NOTE: the format for all calls through this object must be .json

var TagalusAPI = {
  
  api_version : '0001', //this is set to the latest version by default - to use an older API version, you must redefine this
  api_server : 'http://api.tagal.us/', //only should be changed in the event of testing
  //api_server : 'http://api.localtag:3000/',
  api_key : '', //if you set an API key here, it will be tied to every call.  Alternatively, you can specificy api_key in the params of api_call
  
  TAGALUS_LINK : '<a target="_blank" href="http://tagal.us/">Tagalus</a>',
  
  css_file : 'http://tagal.us/stylesheets/tagalus_widget.css',
  css_loaded : false,
  
  remember_api_key : false,
  
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
  
  load_dependencies : function() {
    //THIS DOESN'T FUNCTION RIGHT NOW - needs trigger for when done 
    
    var headTag = document.getElementsByTagName('head')[0]; 
    
    
    if (jQuery == undefined) {
      script = document.createElement('script'); 
      script.id = 'jquery'; 
      script.type = 'text/javascript'; 
      script.src = 'http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js'; 
      headTag.appendChild(script);
    }
    
    widget_css = document.createElement('link');
    widget_css.href = this.css_file;
    widget_css.media = "screen, projection"
    widget_css.rel = "stylesheet"
    widget_css.type = "text/css"
    widget_css.id = "widget_css"
    widget_css.setAttribute("onload","alert('loaded css')")
    
    
    headTag.appendChild(widget_css)
    
    css_tag = document.getElementById('widget_css')
    
    return true;
    
  },
  
  api_key_param : function(k) {
    if (this.api_key == '') {
      return '';
    } else {
      return '&api_key=' + this.api_key;
    }
  },
  
  load_api_key : function() {
    cookie_key = this.readCookie('tagalus_api_key');
    if ((cookie_key != null) && (cookie_key != '')) {
      this.api_key = cookie_key;
      this.remember_api_key = true;
    }
  },
  
  save_api_key : function() {
    if ((this.api_key != null) && (this.api_key != '')) {
      this.createCookie("tagalus_api_key",this.api_key,365)
    }
  },
  
  destroy_saved_api_key : function() {
    this.eraseCookie("tagalus_api_key");
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
  
  
  /****** WIDGET FUNCTIONS ************/
  
  load_widget : function() {
    if (jQuery('#tagalus_widget').length > 0) {
      return //already exists
    }
    
    widget_code = '';
    widget_code += '<div id="tagalus_widget" style="display: none">'
    widget_code += ''
    widget_code += '<div id="tagalus_widget_header"><div class="tagalus_widget_close">close</div><a href="http://tagal.us" target="_blank">@tagalus</a></div>'
    widget_code += '<span id="tagalus_widget_header_msg" class="tagalus_widget_dynamic"></span>'
    widget_code += '<span id="tagalus_widget_definition" class="tagalus_widget_dynamic"></span>'
    widget_code += '<div id="tagalus_forms">'
    widget_code += this.definition_form_code();
    widget_code += '</div>'
    widget_code += '<div id="tagalus_widget_footer"><input type="checkbox" id="tagalus_remember_api_key">Remember your API key</a></div>'
    widget_code += '</div>';
        
    jQuery(document.body).append(widget_code);
    
    if (jQuery('#tagalus_widget').draggable != undefined) {
      jQuery('#tagalus_widget_header').css('cursor','move');
      jQuery('#tagalus_widget').draggable({ handle: '#tagalus_widget_header', cursor: 'move' });
    }
    
    jQuery('.tagalus_widget_close').click(function() { TagalusAPI.hide_widget() });
    
    if (this.remember_api_key) {
      jQuery('#tagalus_remember_api_key').attr('checked',true);
    }
    
    jQuery('#tagalus_remember_api_key').change(function(e) {
      if (e.target.checked) {
        TagalusAPI.save_api_key();
        TagalusAPI.remember_api_key = true;
      } else {
        TagalusAPI.destroy_saved_api_key();
        TagalusAPI.remember_api_key = false;
      }
    })
    
  },
  
  show_widget : function(widgetX, widgetY) {
    jQuery('#tagalus_widget').css('top',widgetY)
    jQuery('#tagalus_widget').css('left',widgetX)
    jQuery('#tagalus_widget').show();
  },
  
  hide_widget : function() {
    jQuery('#tagalus_widget').hide();
  },
  
  toggle_widget : function() {
    if (jQuery('#tagalus_widget:visible').length > 0) {
      TagalusAPI.hide_widget();
    } else {
      TagalusAPI.show_widget();
    }
  },
  
  reset_dynamic_fields : function() {
    
      jQuery('.tagalus_widget_dynamic').val('');
      jQuery('.tagalus_widget_dynamic').html('');
  },
  
  add_buttons_to_elements : function(selector) {
    jQuery('img.tagalus_icon').remove();
    jQuery(selector).append(this.tagalus_icon)
    jQuery('img.tagalus_icon').bind('click', function(e) {
      
      TagalusAPI.reset_dynamic_fields();
      
      the_tag = $(e.target).parent().get(0).text;
      
      if (the_tag.indexOf(' ') != -1) {
        return;
      }
      
      if (the_tag.charAt(0) == "#") {
        the_tag = the_tag.substring(1)
      }
      
      TagalusAPI.widget_set_tag(the_tag)
      TagalusAPI.show_widget(e.pageX,e.pageY);
      return false;
      
    })
  },
  
  bind_to_clicks : function(selector) {
    
    
    jQuery(selector).unbind('click')
    jQuery(selector).bind('click',function(e) {
      
      TagalusAPI.reset_dynamic_fields();
      
      the_tag = e.target.text;
      
      if (the_tag.indexOf(' ') != -1) {
        return;
      }
      
      if (the_tag.charAt(0) == "#") {
        the_tag = the_tag.substring(1)
      }
      
      TagalusAPI.widget_set_tag(the_tag)
      TagalusAPI.show_widget(e.pageX,e.pageY);
      return false;
     })
  },
  
  unbind_cliks : function(selector) {
    jQuery(selector).unbind('click')
  },
  
  widget_set_tag : function(tag) {
    
    jQuery('#tagalus_widget_header_msg').html('Tagalus definition for <a target="_blank" href="http://tagal.us/tag/' + tag + '">#' + tag + '</a>:');
    jQuery('#add_tagalus_tag_name').val("#" + tag);
    TagalusAPI.widget_display_definition("Loading...");
    TagalusAPI.show_tag(tag, function(data) {
      if (data == null) {
        TagalusAPI.widget_display_definition("There is no definition on Tagalus for #" + tag)
        return;
      }
      if (data.error != null) {
        TagalusAPI.widget_display_definition("There was an error retrieving the definition");
        return;
      }
      TagalusAPI.widget_display_definition(data.definition.the_definition)
    })
    
  },
  
  widget_display_definition : function(the_definition) {
    
    jQuery('#tagalus_widget_definition').text(the_definition);
    
  },
  
  definition_form_code : function() {
    if (this.api_key == '') {
      return this.api_form_code();
    }
    
    
    
    add_definition_form_code = '<div id="add_tagalus_definition">'
    add_definition_form_code += '<span>Add your own definition to ' + this.TAGALUS_LINK + ': <br/></span>'
    add_definition_form_code += 'Tag:<br/><input class="tagalus_widget_dynamic" type="text" id="add_tagalus_tag_name" /><br/>'
    add_definition_form_code += 'Definition: <br/>'
    add_definition_form_code += '<textarea class="tagalus_widget_dynamic" id="add_tagalus_definition_the_definition"></textarea><br/>'
    add_definition_form_code += '<input type="submit" value="Submit" onclick="window.TagalusAPI.submit_tagalus_form(); return false;" />'
    add_definition_form_code += '</div>';
    add_definition_form_code += '<a id="enter_api_key_link" href="" onclick="TagalusAPI.enter_api_key_prompt(); return false;">Change API Key</a><br/>';
    

   return add_definition_form_code;
    
  },
  
  api_form_code : function() {
    form_code = '<div  id="api_key_form">';
    form_code += 'If you <a href="" onclick="if (TagalusAPI.enter_api_key_prompt()) { TagalusAPI.display_definition_form(); } return false;">enter an API key</a>, you can add definitions to ' + this.TAGALUS_LINK + '.  <a href="http://blog.tagal.us/api-documentation/">Learn about Tagalus API keys</a>';
    form_code += '</div>'
    return form_code;
  },
  
  display_definition_form : function() {
    
    if (jQuery('#tagalus_forms').find('#add_tagalus_definition').length == 0) {
      jQuery('#api_key_form').remove();
      jQuery('#tagalus_forms').html(TagalusAPI.definition_form_code());
    }
    
    
  },
  
  enter_api_key_prompt : function() {
    prompt_val = '';
    if ((this.api_key != null) && (this.api_key != '')) {
     prompt_val = this.api_key; 
    }
    k = prompt("Enter your Tagalus API Key",prompt_val);
    if ((k != '') && (k != null)) {
      this.api_key = k;
      if (this.remember_api_key) {
        this.save_api_key();
      }
      return true;
    }
    return false;
  },
  
  submit_tagalus_form : function() {
    
    if ((this.api_key == null) || (this.api_key == '')) {
      alert("You must enter a Tagalus API key to use that feature!");
      return;
    }
    
    var user_tag = jQuery('#add_tagalus_tag_name').val();
    var user_def = jQuery('#add_tagalus_definition_the_definition').val();
    TagalusAPI.hide_widget();

    if ((user_tag == '') || (user_def == '')) {

      alert("You must enter both a tag and a definition");
      return;

    }
    
    if (user_tag.charAt(0) == "#") {
      user_tag = user_tag.substring(1)
    }



    //alert(jQuery('#add_tagalus_tag_name').val() + '' + jQuery('#add_tagalus_definition_the_definition').val());
    //return;

    this.create_definition(user_tag,user_def, function(data) {
      if (data.error != null) {
        alert("There was an error: " + data.error);
			  return;
      }
      alert("Your definition has been added to Tagalus!");
    });

    
  },
  
  
  
  
  /***** COOKIE FUNCTIONS ********/
  createCookie : function (name,value,days) {
    //alert("creating cookie")
  	if (days) {
  		var date = new Date();
  		date.setTime(date.getTime()+(days*24*60*60*1000));
  		var expires = "; expires="+date.toGMTString();
  	}
  	else var expires = "";
  	document.cookie = name+"="+value+expires+"; path=/";
  	//alert(document.cookie)
  },

  readCookie : function(name) {
  	var nameEQ = name + "=";
  	var ca = document.cookie.split(';');
  	for(var i=0;i < ca.length;i++) {
  		var c = ca[i];
  		while (c.charAt(0)==' ') c = c.substring(1,c.length);
  		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  	}
  	return null;
  },

  eraseCookie : function(name) {
    //alert("erasing cookie")
  	this.createCookie(name,"",-1);
  },
  
  
  
  tagalus_icon : '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAIAAABMXPacAAAABGdBTUEAANbY1E9YMgAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAPcSURBVHjaYjSe+Z9hFAwcAAggptEgGFgAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAALHQ2oKz6YxDMVxUC3bzabrQwSKAABrNAQMMAAJoNAIGGAAE0GgEDDAACKDRCBhgABBAoxEwwAAggEYjYIABQADRvBlKxcbcz9f3fr65h0uWmUuQW96YauHCJUifCAAIIJpHALBBTS2jXuzsfLquApcsMPSpaBfdAEAAjRZBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgAAajYABBgABNBoBAwwAAmg0AgYYAATQaAQMMAAIoNEIGGAAEECjETDAACCARiNggAFAAI1GwAADgABiNJ75fzQUBhAABNBoDhhgABBAoxEwwAAggEYjYIABQACNRsAAA4AAGo2AAQYAATQaAQMMAAJoNAIGGAAE0GgEDDAACKDRCBhgABBAoxEwwAAggEYjYIABQACNRsAAA4AAGo2AAQYAATQaAQMMAAJoNAIGGAAE0GgEDDAACKDRCBhgABBAoxEwwAAggEYjYIABQACNRsAAA4AAGo2AAQYAATQaAQMMAAJoNAIGGAAE0GgEDDAACKDRCBhgABBAoxEwwAAggEYjYIABQIABAN44FWfP8XuVAAAAAElFTkSuQmCC" class="tagalus_icon">',
  
}

TagalusAPI.load_api_key();
window.TagalusAPI = TagalusAPI;
