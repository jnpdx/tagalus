/******** OPTIONS *********/

var UPDATE_FREQ = 45000;
var URL_BASE = '';


/******** END OPTIONS *****/


/******* STORAGE **********/

MOST_RECENT_TWEET = -1;
youtube_data = null;

/******* END STORAGE *******/

var user_prefs = new Object();
user_prefs['widgets'] = new Object();
user_prefs.widgets['widget_flickrthumbnails'] = "true";
user_prefs.widgets['widget_twittertweets'] = "true";
user_prefs.widgets['widget_youtubevideos'] = "false";
user_prefs.widgets['widget_technoratilinks'] = "false";

var tag_definitions = new Array();

$(document).ready(function() {

	//widgets stuff
	
	//get widget content
	
	//get_widget('widget_twittertweets');
	//get_widget('widget_flickrthumbnails')
	
	if ($('#new_tag_div').length > 0) {
	  $('#new_tag_div').keyup(function() { 
	    length_notify()
	  });
	}
	
	//SUGGEST
	
	$('#suggest').attr('autocomplete','off');
	$(function() {
		$("#suggest").suggest(URL_BASE + "/search_suggest/",{
		onSelect: function() {
				go_to_tag_search_page();
			}
		});
	});
	
	if ($.cookie('user_prefs') != null) {
		user_prefs = JSON.parse($.cookie('user_prefs'))
	}
	
	
	
	if (window['the_tag'] != undefined) {
		setTimeout("refresh_widgets()",UPDATE_FREQ);
		display_user_widget_prefs();
	}

});

function refresh_widgets() {
	
	setTimeout("refresh_widgets()",UPDATE_FREQ);
	
	refresh_tweets();
	
}
 




function go_to_tag_search_page() {
	
	var search_val = $('#suggest').val();
	
	search_val = search_val.replace("#","");
	search_val = search_val.replace(" ","");	
	
	window.location.href= URL_BASE + '/tag/' + escape(search_val);
	
}





function toggle_widget(ob) {
	
	//console.log("toggling widget");
	
	var widget = $(ob).parent();
	
	var widget_name = widget.attr('id');
	
	var show_widget = false;
	
	if (widget.find('.widget_content').is(':hidden')) {
		
		//console.log("widget was hidden");
		//this toggle is going to show the widget
		
		//if there isn't any content, load it
		if (widget.find('.widget_content').html().length < 20) {
			
			//console.log("loading widget content");
			get_widget(widget_name);
			
		} else {
			
			//console.log("widget bod was " + widget.find('.widget_content').html().length + "long");
			
		}
		
		show_widget = true;
		widget.find('img.collapse_x').attr('src','/images/arrow_down.png');
		
	} else {
		
		widget.find('img.collapse_x').attr('src','/images/arrow_right.png');
		widget.find('div.loader').hide();
		
	}
	
	user_prefs.widgets[''+ widget_name] = '' + show_widget;
	
	save_user_pref();
	
	widget.find('.widget_content').toggle('slow');
	
}

function get_widget(widget_title) {
  
	
	if ($('#' + widget_title).length > 0) {
		
		$('#' + widget_title).find('.widget_content').html('');
		//alert("getting widget" + widget_title);
		//put a spinner in
		$('#' + widget_title).find('.loader').html('<img class="ajax_loader" src="/images/loader.gif" alt="loading..."/>');
		
	}
	
	if (widget_title == "widget_twittertweets") {
	  
	  $.getJSON("http://search.twitter.com/search.json?q=" + escape('#' + window['the_tag'] + " OR @" + window['the_tag']) + "&callback=?",
	  
	    function(data) {
	    
	      rendered_data = render_tweets(data);
				
				if (rendered_data == '') {
					
					rendered_data = "There are no tweets to show!"
					
				} else {
				  
				  rendered_data += '<a class="viewmore" href="http://search.twitter.com/search?q=' + escape(window['the_tag']) + '">View more tweets</a>'
				  
				}
				
				$('#' + widget_title).find('.widget_content').html(rendered_data);
				
				$('#' + widget_title).find('.loader').hide();
	    
	    }
	  
	  )
	  
	} else if (widget_title == "widget_flickrthumbnails") {
	  
	  $.getJSON("http://api.flickr.com/services/feeds/photos_public.gne?tags=" + escape(window['the_tag']) + "&tagmode=any&format=json&jsoncallback=?",
	  
	    function(data) {
	    
	      rendered_data = render_flickr_thumbnails(data);
				
				if (rendered_data == '') {
					
					rendered_data = "There are no photos to show!"
					
				} else {
				  
				  rendered_data += '<a class="viewmore" href="http://flickr.com/search/?q=' + window['the_tag'] + '">View more photos</a>'
				  
				}
				
				$('#' + widget_title).find('.widget_content').html(rendered_data);
				
				$('#' + widget_title).find('.loader').hide();
	    
	    }
	  );
	  
	} else if (widget_title == "widget_youtubevideos") {
	  
	  gdataURL = "http://gdata.youtube.com/feeds/api/videos/-/" + escape(window['the_tag']) + "?alt=json-in-script&format=5&jsoncallback=?";
	  
	  // insert the script:
    var s = document.createElement('script');
    s.src = gdataURL;
    document.getElementsByTagName('head')[0].appendChild(s);
    
	  
	  gdata = { io: { handleScriptLoaded: 
	    
	    function(data) {

        //data = eval('(' + data + ')')

	      rendered_data = ''

        
        var feed = data.feed;
        var entries = feed.entry || [];
        var html = ['<ul class="videos">'];
        for (var i = 0; i < entries.length; i++) {
          if (i == 4) {
            break;
          }
          
          var entry = entries[i];
					vid_url = entries[i].media$group.media$content[0].url;
					
					rendered_data += '<div class="youtube_video">';
					rendered_data += '<object type="application/x-shockwave-flash" data="' + vid_url + ';f=gdata_videos" height="150" width="206"><param name="movie" value="' + vid_url + '"></object>' 
					rendered_data += '</div>'
					
				}
				
				if (rendered_data == '') {
					
					rendered_data = "There are no videos to show!"
					
				} else {
				  
				  rendered_data += '<br class="clear_both"/>';

					rendered_data += '<a class="viewmore" href="http://www.youtube.com/results?search_query=' + window['the_tag'] + '">View more videos</a>'
				  
				}


				$('#' + widget_title).find('.widget_content').html(rendered_data);

				$('#' + widget_title).find('.loader').hide();

	    }
    
    
     } };
    
	  
	  /* This would work if Google would use correct JSON callback stuff
	    $.getJSON("http://gdata.youtube.com/feeds/api/videos/-/" + escape(window['the_tag']) + "?alt=json-in-script&format=5&jsoncallback=?",

  	    function(data) {

  	      rendered_data = ''

          
          var feed = data.feed;
          var entries = feed.entry || [];
          var html = ['<ul class="videos">'];
          for (var i = 0; i < entries.length; i++) {
            if (i == 4) {
              break;
            }
            
            var entry = entries[i];
						vid_url = entries[i].media$group.media$content[0].url;
						
						rendered_data += '<div class="youtube_video">';
						rendered_data += '<object type="application/x-shockwave-flash" data="' + vid_url + ';f=gdata_videos" height="150" width="206"><param name="movie" value="' + vid_url + '"></object>' 
						rendered_data += '</div>'
						
					}
					
					if (rendered_data == '') {
						
						rendered_data = "There are no videos to show!"
						
					} else {
					  
					  rendered_data += '<br class="clear_both"/>';

  					rendered_data += '<a class="viewmore" href="http://www.youtube.com/results?search_query=' + window['the_tag'] + '">View more videos</a>'
					  
					}


  				$('#' + widget_title).find('.widget_content').html(rendered_data);

  				$('#' + widget_title).find('.loader').hide();

  	    }
  	  );
	  */
	  
	    //get_widget_old(widget_title)
	    //return;
	  
	}
  
}

function get_widget_old(widget_title) {
	
	var widget_url = widget_title;
	
	if (widget_title.indexOf('widget_') == 0) {
		
		widget_url = widget_title.substring(7);
		
	}
	
	if ($('#' + widget_title).length > 0) {
		
		$('#' + widget_title).find('.widget_content').html('');
		//alert("getting widget" + widget_title);
		//put a spinner in
		$('#' + widget_title).find('.loader').html('<img class="ajax_loader" src="/images/loader.gif" alt="loading..."/>');
		
		$.get(URL_BASE + "/widget/" + widget_url + "/" + the_tag, {
				
			}, function (data) {
				//alert(widget_title);

				
				//alert("Putting widget content in");
				
				var rendered_data = '';
				
				if (widget_title == "widget_twittertweets") {
					rendered_data = render_tweets(data);
					
					if (rendered_data == '') {
						
						rendered_data = "There are no tweets to show!"
						
					} else {
					  
					  rendered_data += '<a class="viewmore" href="http://search.twitter.com/?q=' + window['the_tag'] + '">View more tweets</a>'
					  
					}
					
					
					
				}
				
				if (widget_title == "widget_flickrthumbnails") {
					
					rendered_data = render_flickr_thumbnails(data);
					
					if (rendered_data == '') {
						
						rendered_data = "There are no photos to show!"
						
					} else {
					  
					  rendered_data += '<a class="viewmore" href="http://flickr.com/search/?q=' + window['the_tag'] + '">View more photos</a>'
					  
					}
					
				}
				
				if (widget_title == "widget_youtubevideos") {
					
					
					
					for (v in data) {
						
						if (v == 4) {
							
							break;
							
						}
						
						vid_url = data[v];
						
						rendered_data += '<div class="youtube_video">';
						rendered_data += '<object type="application/x-shockwave-flash" data="' + vid_url + ';f=gdata_videos" height="150" width="206"><param name="movie" value="' + vid_url + '"></object>' 
						rendered_data += '</div>'
						
					}
					
					if (rendered_data == '') {
						
						rendered_data = "There are no videos to show!"
						
					} else {
					  
					  rendered_data += '<br class="clear_both"/>';

  					rendered_data += '<a class="viewmore" href="http://www.youtube.com/results?search_query=' + window['the_tag'] + '">View more videos</a>'
					  
					}
					
					
					
					//youtube_data = data;
					
					//alert(data);
					
				}
				
				$('#' + widget_title).find('.widget_content').html(rendered_data);
				
				$('#' + widget_title).find('.loader').hide();
				
		},'json');
		
	}
	
}

function render_tweets(data) {
	
	var to_ret = "";
	
	if (data.results.length >= 1) {
		
		MOST_RECENT_TWEET = data.results[0].id;
		
		to_ret += "<ul>";
		
		for (i in data.results) {
			
			if (i == 10) {	
				break;	
			}
			
			var tweet = data.results[i];
			//to_ret += "<li>" + tweet.text + "</li>";
			//to_ret += "<br/>";
			
			to_ret += '<div class="twitter_tweet" id="twitter_tweet_' + tweet.id + '">'
			to_ret += 	'<input type="hidden" class="tweet_id" value="' + tweet.id + '"/>'
			to_ret += 	'<img class="twitter_avatar" src="' + tweet.profile_image_url + '" alt="' + tweet.from_user + '"/>'
			to_ret += 	'<span class="tweet_user_name"><a href="http://twitter.com/' + tweet.from_user + '/">@' + tweet.from_user + '</a></span>'
			to_ret += 	'<span class="tweet_text"><a href="http://twitter.com/' + tweet.from_user + '/status/' + tweet.id + '" rel="nofollow">&nbsp;' + tweet.text + '</a></span><br class="clear_both"/>'
			to_ret +=	'<div class="add_buttons">Add as: <a href="/add_tweet/?type=comment&the_tag=' + the_tag + '&tweet_id=' + tweet.id + '">comment</a> or <a href="/add_tweet/?type=definition&the_tag=' + the_tag + '&tweet_id=' + tweet.id + '">definition</a></div>'
			to_ret += '</div>'
			
			
		}
		
		to_ret += "</ul>";
		
		
	}
	
	return to_ret;
	
}

function render_flickr_thumbnails(data) {
	
	var to_ret = "";
	
	if (data.items.length >= 1) {
		
		for (i in data.items) {
			
			if (i == 20) {	
				break;	
			}
			
			var cur_photo = data.items[i];
			to_ret += '<a href="' + cur_photo.link + '">';
			to_ret += '<img alt="Flickr image" class="flickr_thumb" src="' + cur_photo.media.m + '"/></a>';
			
		}
		
	}
	
	return to_ret;
	
}

function refresh_tweets() {
	
	if (user_prefs.widgets.widget_twittertweets == 'false') {
		return;
	}
	
	var since_tweet = $('#widget_twittertweets').find('.twitter_tweet:first').find('.tweet_id').val();
	
	$.getJSON("http://search.twitter.com/search.json?q=" + escape('#' + window['the_tag'] + ' OR @' + window['the_tag']) + "&since_id=" + MOST_RECENT_TWEET + "&callback=?",
		function (data) {
			//alert(widget_title);

			if (data.results.length == 0) {
				
				return;
				
			}
			

			//alert("There are " + data.results.length + " more tweets");
			if (!$('#tweet_refresh_box').length != 0) {
				
				$('#widget_twittertweets').find('.widget_content').prepend('<div id="tweet_refresh_box" style="display:none;"></div>');
				
			}
			
			if (data.results.length == 1) {
				$('#tweet_refresh_box').html('There is one new tweet.  <a href="" onclick="get_widget(\'widget_twittertweets\'); return false;">Refresh?</a>');
				
				
			} else {
				$('#tweet_refresh_box').html('There are ' + data.results.length + ' new tweets.  <a href="" onclick="get_widget(\'widget_twittertweets\'); return false;">Refresh?</a>');
			}
			
			$('#tweet_refresh_box').show('slow');
			
	});
	
}

function save_user_pref() {
	
	$.cookie('user_prefs', JSON.stringify(user_prefs));

}

function display_user_widget_prefs() {
	
	if (user_prefs.length == 0) {
		return;
	}
		
	if (user_prefs.widgets.length == 0) {
		return;
	}
	
	if (user_prefs.widgets.widget_flickrthumbnails == 'true') {
		
		toggle_widget($('#widget_flickrthumbnails').find('.widget_content'));
		
	}
	
	if (user_prefs.widgets.widget_technoratilinks == 'true') {
		
		toggle_widget($('#widget_technoratilinks').find('.widget_content'));
		
	}
	
	if (user_prefs.widgets.widget_twittertweets == 'true') {
		
		toggle_widget($('#widget_twittertweets').find('.widget_content'));
		
		
	}
	
	if (user_prefs.widgets.widget_youtubevideos == 'true') {
		
		toggle_widget($('#widget_youtubevideos').find('.widget_content'));
		
		
	}
		
	
}



//Lets the user know how many more characters are available
function length_notify() {
	
	var input_box = $('#definition_the_definition');
	
	var chars_typed = input_box.val().length;
	
	
	if (chars_typed >= 280) {
		
		//input_box.val(input_box.val().substring(0,140));
		//chars_typed = max_length;
		
	}
	
	tag_form_div = input_box.parent
	
	var char_span = '';
	
	if (chars_typed >= 260) {
		char_span = '<span style="color: red;">';
	} else {
		char_span = '<span>';
	}
	
	if (chars_typed == 0) {
	   $('.length_notify_box').html('');
	} else {
		$('.length_notify_box').html(char_span + (280 - chars_typed) + " characters left</span>");
  }
	
}



