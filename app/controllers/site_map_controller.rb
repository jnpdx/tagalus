class SiteMapController < ApplicationController
  
  def show
    @entries = Tag.find(:all,:order => "updated_at DESC")
    headers["Content-Type"] = "text/xml"
    # set last modified header to the date of the latest entry.
    headers["Last-Modified"] = @entries[0].updated_at.httpdate
  end
  
end
