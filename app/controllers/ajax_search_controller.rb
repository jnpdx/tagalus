class AjaxSearchController < ApplicationController
  layout 'main_template', :except => :show
  
  
  def show
    
    list_of_terms = ""
    
    search_term = params[:q]
    
    @tags = search_tags(search_term)
    
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
    
    @search_term = params[:q]
    @page_title = "Search for " + @search_term
    
    
    if @search_term[0] == 35
      @search_term = @search_term[1..@search_term.length-1]
    end
    
    @tag_exists = false
    
    if (@main_tag = Tag.find_by_the_tag(@search_term))
      @tag_exists = true
    end
    
    @tags = search_tags(@search_term)
    @definitions = search_definitions(@search_term)
    
    #redirect_to '/tag/' + search_term
    
  end
  
  private
  
  def search_tags(search_term)
    Tag.find(:all, :conditions => ('the_tag LIKE "%' + search_term +'%"'))
  end
  
  def search_definitions(search_term)
    @search = ActsAsXapian::Search.new [Definition], search_term, {:limit => 100}
    
    to_ret = []
    
    if @search.results.length != 0
      @search_defs = @search.results.collect {|r| r[:model]}
      
      for @search_def in @search_defs
        to_ret.push({:tag => @search_def.tag, :definition => @search_def})
      end
      
    end
    
    return to_ret
  end
  
end
