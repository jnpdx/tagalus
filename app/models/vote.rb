class Vote < ActiveRecord::Base
  belongs_to :definition
  belongs_to :user
end
