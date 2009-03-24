xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Tagalus"
    xml.description "Recent tags on Tagalus"
    xml.link "http://tagal.us"

    for tag in @tags
      xml.item do
        xml.title tag.the_tag
        xml.description tag.best_definition.the_definition
        xml.pubDate tag.created_at.to_s(:rfc822)
        xml.link 'http://tagal.us/tag/' + tag.the_tag
      end
    end
  end
end
