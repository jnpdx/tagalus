class Definition < ActiveRecord::Base
  belongs_to :tag
  belongs_to :user
  validates_presence_of :the_definition, :message => "You must enter a definition"
  validates_length_of :the_definition, :maximum => 280, :message => "Definition too long - max 280 characters"
  validates_uniqueness_of :the_definition
  
  def texturized_definition
    #this will have the url parsing, tag parsing, etc 
    require 'sanitize'
    old_def = Sanitize.clean self.the_definition
    
    #already done by h
    #old_def.gsub!(/\n/,'<br/>')
    
    regex = Regexp.new '(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
    
    old_def.gsub!(regex,'<a href="\&" target="_blank">\&</a>')
    
    old_def.gsub!(/[#]+([A-Za-z0-9-_]+)/,'<a href="/tag/\\1">#\\1</a>')
    
    return old_def
  end
  
end
