class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :get_version
  
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
  
  def show
    self.send("show_" + @api_version)
  end
  
  def create
    self.send("create_" + @api_version)
  end
  
  def api_error m = nil, e = nil
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
        data_obj = Definition.find(:all, :conditions => { :tag_id => data_name}, :order => 'authority DESC')
      when 'comment'
        data_obj = Comment.find(:all, :conditions => { :tag_id => data_name})
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
    
    
    respond_to do |format|
      format.json { render :json => data_obj.to_json }
      format.xml { render :xml => data_obj.to_xml }
      format.text { render :text => data_obj }
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
       api_user = User.find_by_api_key(@user_api_key)
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
       d.user_id = api_user.id
       
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
         t = Tag.find(params[:tag_id])
       rescue ActiveRecord::RecordNotFound
         api_error "Couldn't find tag"
         return
       end
       d.tag_id = params[:tag_id]
       d.the_definition = params[:the_definition]
       d.user_id = api_user.id
       d.authority = 1
   
       if !d.save
        api_error "Couldn't save definition", d.errors
        return
       end
       
       to_render = d
     
     when 'comment'
       d = Comment.new
        begin
          t = Tag.find(params[:tag_id])
        rescue ActiveRecord::RecordNotFound
          api_error "Couldn't find tag"
          return
        end
        d.tag_id = params[:tag_id]
        d.the_comment = params[:the_comment]
        d.user_id = api_user.id

        if !d.save
         api_error "Couldn't save comment", d.errors
         return
        end

        to_render = d
     when 'user'    
       begin
         u = User.find(data_name)
       rescue ActiveRecord::RecordNotFound
         api_error "Couldn't find user"
         return
       end
       to_render = { :id => u.id, :identity_url => u.identity_url }
    
     else
       api_error "Unknown data type"
       return
     end
     
     respond_to do |format|
       format.json { render :json => to_render.to_json }
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
    
    respond_to do |format|
      format.json { render :json => msg.to_json }
      format.xml { render :xml => msg.to_xml }
      format.text { render :text => msg }
    end
  end
  
end

class TagReturn
  attr_accessor :tag, :definition
end