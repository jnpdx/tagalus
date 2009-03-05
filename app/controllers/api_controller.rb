class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  
  def show
    
    data_obj = nil
    data_name = params[:data_name]
    
    begin
      case params[:data_type]
      when 'tag'
        data_obj = Tag.find_by_the_tag(data_name)
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
  
  def create

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
       to_render = t
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
        end
        d.tag_id = params[:tag_id]
        d.the_comment = params[:the_comment]
        d.user_id = api_user.id

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
       format.json { render :json => to_render.to_json }
       format.xml { render :xml => to_render.to_xml }
       format.text { render :text => to_render }
     end
     
   end
  
  def api_error msg = nil, errors = nil
    
    if msg == nil
      msg = "Unknown API error"
    end

    
    respond_to do |format|
      format.json { render :json => msg.to_json }
      format.xml { render :xml => msg.to_xml }
      format.text { render :text => msg }
    end
  end
  
end

class APIError
  attr_accessor :message, :errors
  
  def error_data 
    [{:message => @message, :errors => @errors }]
  end
  
end