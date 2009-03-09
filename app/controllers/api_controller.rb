class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :get_version
  after_filter :log_api_call
  
  def get_version
    $min_version = '0001'
    $latest_version = '0001'
    @api_version = $latest_version
    
    req_version = params[:api_version]
    
    if req_version != nil
      if (req_version.to_i < $min_version.to_i) || (req_version.to_i > $latest_version.to_i)
        api_error "Unsupported API version", [{:attribute => "max_api_version",:error_message => $latest_version}, {:attribute => "min_api_version",:error_message => $min_version}]
        return
      end
      @api_version = req_version
    end
  end
  
  def javascript_api_interface 
    send_file 'public/javascripts/tagalus_api_interface.js', :type => 'text/javascript'
  end
  
  def log_api_call
    @api_call = ApiCall.new
    @api_call.uri = request.request_uri
    @api_call.success = !@api_error
    if @api_user
      @api_call.user_id = @api_user.id
    end
    if params[:action] == 'create'
      @api_call.postdata = params.to_a.join ','
    end
    @api_call.save
  end
  
  def show
    self.send("show_" + @api_version)
  end
  
  def create
    self.send("create_" + @api_version)
  end
  
  def api_error m = nil, e = nil
    @api_error = true
    self.send("api_error_" + @api_version,m,e)
  end
  
  
  ####### API VERSION 0001 #########
  
  def show_0001
    
    data_obj = nil
    data_name = params[:data_name]
    
    begin
      case params[:data_type]
      when 'tag'
        data_obj = Tag.find_by_the_tag(data_name)
        if data_obj
          d = Definition.find(:first, :conditions => { :tag_id => data_obj.id}, :order => 'authority DESC')
          to_ret = data_obj.attributes
          data_obj = to_ret.merge ({'definition' => d.attributes})
        end
      when 'definition'
        t = Tag.find_by_the_tag(data_name)
        if t
          data_obj = Definition.find(:all, :conditions => { :tag_id => t.id}, :order => 'authority DESC')
        end
      when 'comment'
        t = Tag.find_by_the_tag(data_name)
        if t
          data_obj = Comment.find(:all, :conditions => { :tag_id => t.id})
        end
      when 'user'
        u = User.find(data_name)
        if u != nil
          data_obj = { :id => data_name, :identity_url => u.identity_url }
        end
      else
        api_error "Unknown data type"
        return
      end
    rescue ActiveRecord::RecordNotFound
      data_obj = nil
    end
    
    to_render = data_obj
    respond_to do |format|
       if params[:callback]
         format.json { render :json => ( params[:callback] + '(' + to_render.to_json + ')') }
       else
         format.json { render :json => to_render.to_json }
       end
       format.xml { render :xml => to_render.to_xml }
       format.text { render :text => to_render }
     end
    
  end
  
  def create_0001

    to_render = nil

     @user_api_key = params[:api_key]
     if @user_api_key == nil
       api_error "Must authenticate request with an API key"
       return
     end

     begin
       @api_user = User.find_by_api_key(@user_api_key)
     rescue ActiveRecord::RecordNotFound
       api_error "Non-valid API key"
       return
     end

     case params[:data_type]
     when 'tag'
       t = Tag.new
       t.the_tag = params[:the_tag]
       if !t.save
         api_error "Couldn't save tag", t.errors
         return
       end
       
       d = Definition.new
       
       d.the_definition = params[:the_definition]
       d.tag_id = t.id
       d.user_id = @api_user.id
       
       if !d.save
         api_error "Couldn't save definition - tag not saved either", d.errors
         t.destroy
         return
       end
       
       to_ret = t.attributes
       to_render = to_ret.merge ({'definition' => d.attributes})
       
       
       
       #to_render = { 'tags' => t, 'definitions' => d }
       #to_render = ApiAccessor.new
       #to_render.tag = t
       #to_render.definition = d
     when 'definition'
       d = Definition.new
       begin
         if params[:tag_id] != nil
           t = Tag.find(params[:tag_id])
         else
           t = Tag.find_by_the_tag(params[:the_tag])
         end
       rescue ActiveRecord::RecordNotFound
         api_error "Couldn't find tag"
         return
       end
       d.tag_id = t.id
       d.the_definition = params[:the_definition]
       d.user_id = @api_user.id
       d.authority = 1
   
       if !d.save
        api_error "Couldn't save definition", d.errors
        return
       end
       
       to_render = d
     
     when 'comment'
       d = Comment.new
        begin
          if params[:tag_id] != nil
             t = Tag.find(params[:tag_id])
           else
             t = Tag.find_by_the_tag(params[:the_tag])
           end
        rescue ActiveRecord::RecordNotFound
          api_error "Couldn't find tag"
          return
        end
        d.tag_id = t.id
        d.the_comment = params[:the_comment]
        d.user_id = @api_user.id

        if !d.save
         api_error "Couldn't save comment", d.errors
         return
        end

        to_render = d
    
     else
       api_error "Unknown data type"
       return
     end
     
     respond_to do |format|
       if params[:callback]
         format.json { render :json => ( params[:callback] + '(' + to_render.to_json + ')') }
       else
         format.json { render :json => to_render.to_json }
       end
       format.xml { render :xml => to_render.to_xml }
       format.text { render :text => to_render }
     end
     
   end
  
  def api_error_0001 message = nil, errors = nil
    
    if message == nil
      message = "Unknown API error"
    end

    errors_list = nil
    
    if errors != nil
      errors_list = []
      
      if errors.class == ActiveRecord::Errors
        errors.each{ |attrib,err_msg|
          errors_list << { :attribute => attrib, :error_message => err_msg }
        }
      else
        errors_list = errors
      end
      
    end

    msg = { :error => message, :errors => errors_list }
    
    to_render = msg
    respond_to do |format|
       if params[:callback]
         format.json { render :json => ( params[:callback] + '(' + to_render.to_json + ')') }
       else
         format.json { render :json => to_render.to_json }
       end
       format.xml { render :xml => to_render.to_xml }
       format.text { render :text => to_render }
     end
     
  end
  
end

class TagReturn
  attr_accessor :tag, :definition
end