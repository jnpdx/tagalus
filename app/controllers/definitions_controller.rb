class DefinitionsController < ApplicationController
  
  def create
    if !logged_in?
      cookies[:saved_def] = Marshal.dump(params)
      flash[:error] = "You have to login before you can add a definition!"
      redirect_to '/login'
      return
    end
    
    @tag = Tag.find_or_create_by_the_tag(params[:the_tag])
    
    @tag.updated_at = DateTime.now
        
    @definition = Definition.new(params[:definition])
    @definition.user_id = current_user.id
    @definition.tag_id = @tag.id
    if (@definition.save)
      #render :text => "saved definition"
      @tag.save
      
      flash[:notice] = "Your definition was added to #" + @tag.the_tag
      redirect_to '/tag/' + @tag.the_tag
    else 
      flash[:error] = "You need to enter a definition"
      
      @definition.errors.each{|attr,msg| flash[:error] = msg}
      redirect_to '/tag/' + @tag.the_tag
    end
  end
  
  def vote
    if !logged_in?
      flash[:error] = "You have to login before you can vote on a definition!"
      redirect_to '/login'
      return
    end
    
    @def = Definition.find_by_id(params[:def_id])
    @tag = Tag.find_by_id(@def.tag_id)
    
    if Vote.find(:first, :conditions => { :user_id => current_user.id, :definition_id => @def.id }) != nil
      flash[:error] = "You've already voted on that definition!"
      redirect_to '/tag/' + @tag.the_tag
      return
    end
    
    # okay, vote on it
    
    @vote = Vote.new
    @vote.user_id = current_user.id
    @vote.definition_id = @def.id
    
    @vote.save
    
    @def.authority = @def.authority + 1
    @def.save
    
    flash[:notice] = "Your vote has been counted"
    redirect_to '/tag/' + @tag.the_tag
    
  end
  
end
