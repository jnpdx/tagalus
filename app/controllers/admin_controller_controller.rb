class AdminControllerController < ApplicationController
  layout 'main_template'
  before_filter :is_admin?
  
  def index
    render :html => 'index'
  end
  
  def create_user
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "saved the user"
    else 
      flash[:notice] = "could not save user"
    end
    redirect_to '/admin'
  end
  
  def create_tagdef
    @tag = Tag.find_or_create_by_the_tag(params[:tag])
    if @tag != nil
      @def = Definition.new(params[:definition])
      @def.tag_id = @tag.id
      @def.user_id = User.find_by_identity_url(params[:user][:identity_url]).id
      if @def.save
        flash[:notice] = "saved tag and def"
      else 
        flash[:error] = "couldn't save def"
      end
      
    else
      flash[:error] = "couldn't make tag"
    end
    redirect_to '/admin'
  end
  
end
