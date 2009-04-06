class StaticDisplayController < ApplicationController
  layout 'main_template'
  
  
  def show
    
    
    
  end
  
  def favicon_redirect
    redirect_to '/favicon.png'
  end
  
end
