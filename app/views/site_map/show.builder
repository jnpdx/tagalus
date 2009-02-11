xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @entries.each do |entry|
    xml.url do
      #xml.loc url_for(:controller => 'tags', 
      #                :action => 'show', 
      #                :id => entry.id,
      #                :only_path => false)
      xml.loc 'http://tagal.us/tag/' + entry.the_tag
      xml.lastmod entry.updated_at.to_date
      xml.changefreq 'daily'
      xml.priority '0.8'
    end
  end
  t = Time.now
  xml.url do
    xml.loc 'http://tagal.us'
    xml.lastmod t.strftime("%Y-%m-%d")
    xml.changefreq 'daily'
    xml.priority '1.0'
  end
  xml.url do
    xml.loc 'http://tagal.us/about'
    xml.lastmod "2008-12-18"
    xml.changefreq 'monthly'
    xml.priority '0.2'
  end
  xml.url do
    xml.loc 'http://tagal.us/login'
    xml.lastmod "2008-12-18"
    xml.changefreq 'monthly'
    xml.priority '0.2'
  end
end