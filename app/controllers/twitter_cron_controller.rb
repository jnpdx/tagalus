require 'json'


class TwitterCronController < ApplicationController
  
  def grab_tagref
    page = 1
    
    if params[:p] != nil
      page = params[:p].to_i
    end
    
    url = "http://search.twitter.com/search.json?rpp=40&q=tagref&page=#{page}";	
  
    search_json_data = Net::HTTP.get_response(URI.parse(url))
  
    data = JSON.parse(search_json_data.body)
    
    to_ret = ''
    
    if data['results'] == nil
      return
    end
    
    data['results'].reverse! #do the oldest ones first, so that they appear correctly in ordering
    
    
    for i in data['results']
      to_ret += i['text'] + '<br/>'
      cur_tweet = i['text']
      cur_user = i['from_user']
      tweet_id = i['id']
      
      #to_ret += "parsing tweet #{cur_tweet} from #{cur_user}<br/>"
      
    
      if TweetChecked.find_by_tweet_id(i['id']).nil?
        t = TweetChecked.new(:tweet_id => tweet_id)
        t.save
        to_ret += "made new object and saved<br/>"
      else
        to_ret += "Already checked this one!<br/>"
        next
      end
      
      words = cur_tweet.split(' ')
      
      to_ret += "Length of tweet: " + words.length.to_s + "<br/>"
      
      
      
      if words[0] != '@tagref'
        to_ret += 'Not to tagref<br/>'
        next
      end
      
      the_tag = words[1]
      
      if the_tag[0] == 35  #this checks if it's a hash mark (#)
        the_tag = the_tag[1..(the_tag.length-1)]
        to_ret += "the tag is #{the_tag}<br/>"
      else 
        to_ret += "not a hashtag<br/>"
        next
      end
      
      if words.length < 4
        to_ret += "too short!<br/>"
        next
      end
      
      if words[2] == 'is'
        the_def = words[3..(words.length - 1)].join(' ')
      else
        the_def = words[2..(words.length - 1)].join(' ')
      end
      
      to_ret += "going to define it as: " + the_def + "<br/>"
      
      
      @tag = Tag.find_or_create_by_the_tag(the_tag)
      
      if @tag.id == nil
        to_ret += "Couldn't get tag!<br/><br/>"
        next
      end
      
      
      @user = User.find_or_create_by_identity_url('http://twitter.com/' + cur_user)
      
      
      @def = Definition.new(:the_definition => the_def,:tag_id => @tag.id, :user_id => @user.id)
      
      if @def.save
        to_ret += 'saved'
        to_ret += tweet_back(cur_user,tweet_id,"http://tagal.us/tag/#{the_tag} " + '#' + the_tag)
      else
        #to_ret += tweet_back(cur_user,tweet_id,"There was a problem - we probably already have that definition")
      end
      
      to_ret += "<br/><br/>"
      
    end
    
    if params[:v] != nil
      render :text => $to_render + '<br/><br/>' + to_ret + "<br/>"
    else
      render :text => 'done'
    end
    
  end
  
  def show
    #this is the cron job
    
    page = 1
    
    if params[:p] != nil
      page = params[:p].to_i
    end
    
    url = "http://search.twitter.com/search.json?rpp=40&q=tagalus&page=#{page}";	
  
    search_json_data = Net::HTTP.get_response(URI.parse(url))
  
    data = JSON.parse(search_json_data.body)
    
    to_ret = ''
    
    if data['results'] == nil
      return #no results
    end
    
    data['results'].reverse! #do the oldest ones first, so that they appear correctly in ordering
    
    for i in data['results']
      to_ret += i['text'] + '<br/>'
      cur_tweet = i['text']
      cur_user = i['from_user']
      tweet_id = i['id']
      
      if TweetChecked.find_by_tweet_id(i['id']).nil?
        t = TweetChecked.new(:tweet_id => tweet_id)
        t.save
        to_ret += "made new object and saved<br/>"
      else
        to_ret += "Already checked this one!<br/>"
        next
      end
      
      words = cur_tweet.split(' ')
      
      if (words[0] != "@tagalus")
        to_ret += "Not to me<br/>"
        next
      end
      
      if words.length < 3
        to_ret += "not long enough<br/>"
        next
      end
      
      if words[1] != 'define'
        to_ret += "not defining<br/>"
        next
      end
      
      the_tag = words[2]
      
      if the_tag[0] == 35  #this checks if it's a hash mark (#)
        the_tag = the_tag[1..(the_tag.length-1)]
      end
      
      if words.length == 3
        
        #define the tag
        @tag = Tag.find_by_the_tag(the_tag)
        if @tag != nil
          @definition = Definition.find(:first, :conditions => { :tag_id => @tag.id })
          to_ret += @definition.the_definition + "<br/>"
          to_ret += tweet_back(cur_user,tweet_id,'#' + "#{the_tag} = " + @definition.the_definition)
          next
        else
          to_ret += "couldn't find a defintion for that"
          to_ret += tweet_back(cur_user,tweet_id,"I don't have a definition for #{the_tag} yet")
          next
        end
      end
        
      #okay, we need to define it
      
      #should have a while.. loop that checks for different syntaxes and sets vars, eg the_tag and the_def
      
      if words.length < 5
        to_ret += "not long enough<br/>"
        next
      end
      
      if words[3] != 'as'
        to_ret += "how do I define it?<br/>"
        next
      end
      
      the_def = words[4..(words.length - 1)].join(' ')
      
      to_ret += "going to define it as: " + the_def + "<br/>"
      
      @tag = Tag.find_or_create_by_the_tag(the_tag)
      @user = User.find_or_create_by_identity_url('http://twitter.com/' + cur_user)
      
      
      @def = Definition.new(:the_definition => the_def,:tag_id => @tag.id, :user_id => @user.id)
      
      
      if @def.save
        to_ret += 'saved'
        to_ret += tweet_back(cur_user,tweet_id,"http://tagal.us/tag/#{the_tag} " + '#' + the_tag)
      else
        to_ret += tweet_back(cur_user,tweet_id,"There was a problem - we probably already have that definition")
      end
      
    end
    
    #render :text => to_ret + "<br/>"
    
    $to_render = to_ret
    
    grab_tagref
    
  end
  
  def tweet_back(to_user,tweet_id,message)
    tw_user = AppPref.find_by_pref_key('tw_agent_name').pref_val
    tw_pass = AppPref.find_by_pref_key('tw_agent_pass').pref_val
    
    msg = "@#{to_user} #{message}"
    
    if msg.length > 140
      msg = msg[0..136] + '...'
    end
    
    require 'cgi'
    
    #msg = CGI.escape(msg)
    
    url = URI.parse("http://twitter.com/statuses/update.json")
    
    #query_string = "status=#{msg}&in_reply_to_status_id=#{tweet_id}"
    
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({'status' => msg, 'in_reply_to_status_id' => tweet_id})
    req.basic_auth tw_user, tw_pass
    
    if ENV['RAILS_ENV'] == 'production'
      res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
       return res.body + '<br/>'
    end
    
    return "sent tweet to http://twitter.com/statuses/update.json?status=#{msg}&in_reply_to_status_id=#{tweet_id} <br/>"
    
  end
  
  
end
