class TagsController < ApplicationController
  before_filter :login_required, :only => [:update, :destroy]
  
  # GET /tags
  # GET /tags.xml
  layout 'main_template' 

  def index
    #check for the no_track flag
    if params[:track] != nil
      $track = false
      cookies[:notrack] = {
         :value => 'true',
         :expires => 1.year.from_now,
       }
      
    end
    
    if params[:do_create] != nil
      create
      return
    end
    
    @page_title = "Welcome!"
    
    @page = params[:p]
    
    if @page == nil
      @page = 1
    else
      @page = @page.to_i
    end
    
    @tags = Tag.find(:all, :order => 'updated_at DESC');
    
    @total_tags = @tags.length
  
    @next_pages = false
    @prev_pages = false
  
    if @page > 1
      @prev_pages = true
    end
  
    if @page == 1
      range_min = 0
    else 
      range_min = ($tags_per_page * (@page - 1)) - 1
    end
    
    range_max = (range_min + $tags_per_page) - 1
    
    if range_min < @total_tags
      if range_max >= @total_tags
        @tags = @tags[range_min..@total_tags-1]
      else
        @tags = @tags[range_min..range_max]
        @next_pages = true
      end
    end
    
    

    send_email('tagalus@gmail.com', 'Tagalus AutoMail', 'tagalus@gmail.com', 'Tagalus', 'Auto mail', 'this is a test')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    if params[:id] != nil
      @tag = Tag.find(params[:id])
    else  
      @tag = Tag.find(:first, :conditions => { :the_tag => params[:the_tag]} )
    end
    
    if @tag != nil
      #@definitions = @tag.definitions
      @definitions = Definition.find(:all,:order => "authority DESC, created_at ASC", :conditions => { :tag_id => @tag.id })
    else 
      @definitions = nil
    end
    
    if @definitions != nil
      @main_def = @definitions[0].texturized_definition
    else 
      @main_def = "This tag hasn't been defined yet - be the first one to define it by using the form below!"
    end
    
    if @tag != nil
      @the_tag = @tag.the_tag
    else
      @the_tag = params[:the_tag]
      @tag = Tag.new
    end
    
    @page_title = @the_tag

    @d = @tag.definitions.build
    
    @comments = @tag.comments

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new
    @definition = Definition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
    
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    if !logged_in?
      cookies[:saved_tag] = Marshal.dump(params[:tag])
      cookies[:saved_def] = Marshal.dump(params[:definition])
      flash[:error] = "You have to log in before you can add a tag!  Your tag will be added automatically once you log in"
      redirect_to '/login'
      return
    end
    
    if params[:tag][:the_tag].index(' ')  != nil
      flash[:error] = "Sorry, but tags can't include spaces"
      redirect_to ':action => "index"'
      return
    end
    if params[:definition][:the_definition] == ''
      flash[:error] = "Your tag must have a definition"
      redirect_to :action => "index"
      return
    end
    if Definition.find_by_the_definition(params[:definition][:the_definition]) != nil
      flash[:error] = "Sorry, but something already has that definition"
      redirect_to :action => "index"
      return
    end
    
    #if param[:tag][:the_tag][0] == '#'
    
    @tag = Tag.find_or_initialize_by_the_tag(params[:tag][:the_tag])
    @tag.updated_at = DateTime.now
    
    @d = Definition.new(params[:definition])
    @d.user_id = current_user.id

    respond_to do |format|
      
      if @tag.save
        @d.tag_id = @tag.id
        @d.save
        send_admin_dm "New tag: http://tagal.us/tag/" + @tag.the_tag
        flash[:notice] = 'Your tag has been added to Tagalus!'
        format.html { redirect_to("/tag/" + @tag.the_tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  
end
