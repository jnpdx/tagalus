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
  
end