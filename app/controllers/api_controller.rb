class ApiController < ApplicationController
  
  def show
    
    data_obj = nil
    data_name = params[:data_name]
    
    case params[:data_type]
    when 'tag'
      data_obj = Tag.find_by_the_tag(data_name)
    when 'definition'
      data_obj = Definition.find_by_the_definition(data_name)
    when 'comment'
      data_obj = Comment.find(data_name) #this is by ID
    else
      api_error
      return
    end
    
    respond_to do |format|
      format.json { render :json => data_obj.to_json }
      format.xml { render :xml => data_obj.to_xml }
      format.text { render :text => data_obj }
    end
    
  end
  
  def api_error
    render :text => "API ERROR"
  end
  
end
