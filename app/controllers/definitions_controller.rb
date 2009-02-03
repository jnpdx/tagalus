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
  
end
