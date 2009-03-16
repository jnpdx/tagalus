class AjaxSearchController < ApplicationController
  
  def show
    
    list_of_terms = ""
    
    search_term = params[:q]
    
    @tags = Tag.find(:all, :conditions => ('the_tag LIKE "%' + search_term +'%"'))
    
    @search = ActsAsXapian::Search.new [Definition], search_term, {:limit => 10}
    
    if @search.results.length != 0
      @search_defs = @search.results.collect {|r| r[:model]}
      @search_tags = []
      
      for @search_def in @search_defs
        @search_tags.push @search_def.tag
      end
      
      @tags += @search_tags
      @tags.uniq!
    end
    
    for i in @tags
      
      list_of_terms << i.the_tag + "\n"
      
    end
    
    render :text => list_of_terms
    
  end
  
  def search
    
    search_term = params[:suggest]
    
    if search_term[0] == 35
      search_term = search_term[1..search_term.length-1]
    end
    
    redirect_to '/tag/' + search_term
    
  end
  
end
