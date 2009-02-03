# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'main_template'
  
  # render new.rhtml
  def new
    @page_title = "Login"
  end
  
  def new_twitter
    @page_title = "Login"
  end

  def create
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      twitter_authentication(params[:login],params[:password])
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected
  
  def open_id_authentication(openid_url)
    #flash[:notice] = "URL: " + openid_url
    #redirect_to '/'
    #return
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(OpenIdAuthentication.normalize_url(identity_url))
        if @user.new_record?
          @user.login = registration['nickname']
          @user.email = registration['email']
          @user.save(false)
        end
        self.current_user = @user
        successful_login
      else
        failed_login result.message
      end
    end
  end
  
  def twitter_authentication(user_n,pass)
    if authenticate_twitter_user(user_n,pass)
      @user = User.find_or_initialize_by_identity_url('http://twitter.com/' + user_n)
      @user.save
      self.current_user = @user
      successful_login
    else
      failed_login "Your twitter user/password didn't authenticate"
    end
  end
  
  def password_authentication(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      successful_login
    else
      failed_login
    end
  end
  
  def failed_login(message = "Authentication failed.")
    flash.now[:error] = message
    render :action => 'new'
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    if cookies[:saved_tag] != nil
      tag_params = Marshal.load(cookies[:saved_tag])
      def_params = Marshal.load(cookies[:saved_def])
      cookies.delete :saved_tag
      cookies.delete :saved_def
      
      redirect_to :controller => 'tags', :action => 'create', :do_create => 'true', :tag => tag_params, :definition => def_params
      return
    end
    
    if cookies[:saved_def] != nil
      def_params = Marshal.load(cookies[:saved_def])
      cookies.delete :saved_def
      
      redirect_to :controller => 'tags', :action => 'create', :do_create => 'true', :tag => {:the_tag => def_params[:the_tag]}, :definition => def_params[:definition]
      return
    end
    
    redirect_back_or_default('/')
    flash[:notice] = "Logged in successfully"
    
  end
end
