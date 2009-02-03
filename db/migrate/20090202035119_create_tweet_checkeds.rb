class CreateTweetCheckeds < ActiveRecord::Migration
  def self.up
    create_table :tweet_checkeds do |t|
      t.integer :tweet_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_checkeds
  end
end
