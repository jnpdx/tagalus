class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  validates_length_of :the_comment, :maximum => 400, :message => "Comment too long - max 280 characters"
  validates_presence_of :the_comment
  
  def texturized_comment
    #this will have the url parsing, tag parsing, etc 
    require 'sanitize'
    old = Sanitize.clean self.the_comment
    
    #already done by h
    #old_def.gsub!(/\n/,'<br/>')
    
    regex = Regexp.new '(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
    
    old.gsub!(regex,'<a href="\&" target="_blank">\&</a>')
    
    old.gsub!(/[#]+([A-Za-z0-9-_]+)/,'<a href="/tag/\\1">#\\1</a>')
    
    return old
  end
  
end
