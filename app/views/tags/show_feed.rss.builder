xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@tag.the_tag} - Tagalus"
    xml.description "Definitions for #{@tag.the_tag}"
    xml.link "http://tagal.us/tag/#{@tag.the_tag}"

    for d in @definitions
      xml.item do
        xml.title "Definition for #{@tag.the_tag}"
        xml.description d.the_definition
        xml.pubDate d.created_at.to_s(:rfc822)
        xml.link 'http://tagal.us/tag/' + @tag.the_tag
      end
    end
  end
end
