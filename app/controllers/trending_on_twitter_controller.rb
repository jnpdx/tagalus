class TrendingOnTwitterController < ApplicationController
  include TwitterTools
  layout 'main_template' 
  
  
  def show
    
    @trending = get_trending_terms
    @page_title = "Trending on Twitter"
    
  end
  
end
