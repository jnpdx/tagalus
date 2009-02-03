class WidgetController < ApplicationController

  def show
    @widget_title = params[:widget_title]
    @the_tag = params[:the_tag]
    
    require 'uri'
    require 'net/http'
    
    if @widget_title == 'twittertweets'
      url = "http://search.twitter.com/search.json?q=" + @the_tag
      
      if params[:since_id] != nil
        url += '&since_id=' + params[:since_id]
      end
      
      twitter_data = Net::HTTP.get_response(URI.parse(url))
      
      render :json => twitter_data.body
    elsif @widget_title == 'flickrthumbnails'
      flickr_key = '0b6c74f24f98e19024049056281e7fd3'
      require 'cgi'
      
      flickr_params = "nojsoncallback=1&api_key=#{flickr_key}&method=flickr.photos.search&tags=" + CGI.escape(@the_tag) + "&machine_tag_mode=any&format=json"
      # 'api_key'	=> @@flickr_key,
    	#	'method'	=> 'flickr.photos.search',
    	#	'tags'	=> @the_tag,
    	#	'machine_tag_mode' => 'any',
    	#	'format'	=> 'json',
      #
      url = "http://api.flickr.com/services/rest/?" + flickr_params
      
      flickr_data = Net::HTTP.get_response(URI.parse(url))
      
      render :json => flickr_data.body
    
    elsif @widget_title == 'youtubevideos'
      
      require 'youtube_g'
      
      youtube_client = YouTubeG::Client.new
      
      vids = youtube_client.videos_by(:query => @the_tag)
      
      to_ret = []
      
      for v in vids.videos
        if v.noembed == false
          video_url = v.media_content[0].url
          to_ret << video_url #+ "\n"
        end
      end
      
      #render :json => "This string object"
      render :json => to_ret.to_json
    
    else 
      render :json => "widget not found"
    end
    
  end

end