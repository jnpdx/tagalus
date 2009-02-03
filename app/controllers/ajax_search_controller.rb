class AjaxSearchController < ApplicationController
  
  def show
    
    list_of_terms = ""
    
    search_term = params[:q]
    
    @tags = Tag.find(:all, :conditions => ('the_tag LIKE "%' + search_term +'%"'))
    
    
    for i in @tags
      
      list_of_terms << i.the_tag + "\n"
      
    end
    
    render :text => list_of_terms
    
  end
  
end
