class CommentsController < ApplicationController

  # POST /comments
  # POST /comments.xml
  def create
    @tag = Tag.find_by_id(params[:tag_id])
    if !logged_in?
      flash[:error] = "You have to be logged in to add a comment!"
      redirect_to '/login'
      return
    end
    
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.tag_id = @tag.id

    if @comment.the_comment == ''
      flash[:error] = "Your comment cannot be blank"
      redirect_to '/tag/' + @tag.the_tag
      return
    end

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Your comment was added'
        format.html { redirect_to '/tag/' + @tag.the_tag }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { 
          flash[:error] = "There was a problem adding your comment"
          redirect_to '/tag/' + @tag.the_tag
         }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end


end
