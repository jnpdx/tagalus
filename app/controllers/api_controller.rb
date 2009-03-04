class ApiController < ApplicationController
  
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
  
  def api_error msg = nil
    if msg == nil
      msg = "Unknown API error"
    end
    
    msg = { "api_error" => msg }
    
    respond_to do |format|
      format.json { render :json => msg.to_json }
      format.xml { render :xml => msg.to_xml }
      format.text { render :text => msg }
    end
  end
  
end
