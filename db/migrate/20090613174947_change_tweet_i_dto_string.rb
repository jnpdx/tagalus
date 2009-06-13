class ChangeTweetIDtoString < ActiveRecord::Migration
  def self.up
    change_column :tweet_checkeds, :tweet_id, :string
  end

  def self.down
    change_column :tweet_checkeds, :tweet_id, :integer
  end
end
