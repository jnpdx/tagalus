require 'uri'
require 'net/http'
require 'json'

module TwitterTools
  
  def get_twitvatar_url(user_n)
  
    url = "http://twitter.com/users/show/#{user_n}.json";	
  
    user_data = Net::HTTP.get_response(URI.parse(url))
  
    json_data = JSON.parse(user_data.body)
    
    return json_data['profile_image_url']
  
  end
  
  def authenticate_twitter_user(user_n,pass)
    
    url = URI.parse "http://twitter.com/account/verify_credentials.json"
    
    req = Net::HTTP::Get.new(url.path)
    req.basic_auth user_n, pass
    
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
      }
    case res
    when Net::HTTPSuccess
      return true
    end
    
    return false
    
  end
  
  def send_admin_dm(msg)
    
    tw_user = AppPref.find_by_pref_key('tw_agent_name').pref_val
    tw_pass = AppPref.find_by_pref_key('tw_agent_pass').pref_val
    
    url = URI.parse "http://twitter.com/direct_messages/new.json"
    
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({'user' => 'test_dummy','text' => CGI.escape(msg)})
    req.basic_auth tw_user, tw_pass

    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    
  end
  
end