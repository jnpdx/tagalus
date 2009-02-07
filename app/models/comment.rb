class Comment < ActiveRecord::Base
  include TwitterTools
  belongs_to :user
  belongs_to :tag
  validates_length_of :the_comment, :maximum => 400, :message => "Comment too long - max 280 characters"
  validates_presence_of :the_comment
  validates_uniqueness_of :the_comment
  
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
		  #to_ret = '<img class="subavatar" src="' + get_twitvatar_url(on_behalf) + '"/>'
		  to_ret += "#{self.user.get_display_name} thought that this tweet from #{on_behalf} would make a good comment"
		else 
		  to_ret = "#{self.user.get_display_name} said"
		end 
		to_ret += ':'
		
		return to_ret
  end
  
end
