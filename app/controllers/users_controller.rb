class UsersController < ApplicationController
  layout 'main_template'

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      redirect_to '/'
    end
  end
  
  def update
    @page_title = "Edit User Details"
    if !logged_in?
      access_denied
      return
    end
    
    @user = User.find(current_user.id)
    
    if (@user.api_key == nil) || (params[:new_api_key] != nil)
      #generate an api key for the user
      @user.create_api_key!
    end
    
    if params[:user] != nil
      
      try_save = true
      
      if params[:user][:login].length > 30
        flash[:error] = "Your nickname was too long"
        try_save = false
      end
      if params[:user][:email].length > 100
        flash[:error] = "Your email address was too long"
        try_save = false
      end
            
      @user.login = params[:user][:login]
      @user.email = params[:user][:email]
    
      if try_save
        if @user.save
          flash[:notice] = "Your information was updated"
        else
          flash[:error] = "There was a problem updating your information"
        end
      end
    
    end
    
  end
  
  
  #oAuth stuff
  def self.consumer
    # The readkey and readsecret below are the values you get during registration
    OAuth::Consumer.new(AppPref.find_by_pref_key('oauth_consumer_key').pref_val,
                        AppPref.find_by_pref_key('oauth_consumer_secret').pref_val,
                        { :site=>"http://twitter.com" })
  end
  
  def oauth_create
      @request_token = UsersController.consumer.get_request_token
      session[:request_token] = @request_token.token
      session[:request_token_secret] = @request_token.secret
      # Send to twitter.com to authorize
      redirect_to @request_token.authorize_url
      return
  end
  
  

end