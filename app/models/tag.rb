class Tag < ActiveRecord::Base
  has_many :definitions
  has_many :comments
  validates_presence_of :the_tag
  validates_length_of :the_tag, :maximum => 100, :message => 'Sorry, but your tag cannot be longer than 100 characters'
  validates_uniqueness_of :the_tag, :message => 'We already have that tag!'
end
