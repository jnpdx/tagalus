# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'rubygems'
require 'openid'
require 'twitter_tools'
require 'email_tools'
require 'net/http'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include EmailTools
  include TwitterTools
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '9a7039cd7d5b91bc40ccd934c46c29d8'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  
  $tags_per_page = 5
  
  $track = true
    
end
