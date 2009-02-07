class Definition < ActiveRecord::Base
  include TwitterTools
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
  
  def attribution_text
    to_ret = ''
    on_behalf = ''
    if self.meta_info != nil
		  if (Marshal.load(self.meta_info))['added_for'] != nil
				on_behalf = (Marshal.load(self.meta_info))['added_for']
			end
		end 
		if on_behalf != '' 
		  to_ret = '<img class="subavatar" src="' + get_twitvatar_url(on_behalf[1..on_behalf.length-1]) + '"/>'
		  to_ret += "#{self.user.get_display_name} thought that this tweet from #{on_behalf} would make a good defintion"
		else 
		  to_ret = "Added by #{self.user.get_display_name}"
		end 
		to_ret += ':'
		
		return to_ret
  end
  
end
