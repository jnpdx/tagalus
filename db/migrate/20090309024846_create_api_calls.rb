class CreateApiCalls < ActiveRecord::Migration
  def self.up
    create_table :api_calls do |t|
      t.string :uri
      t.string :postdata
      t.integer :user_id
      t.boolean :success

      t.timestamps
    end
  end

  def self.down
    drop_table :api_calls
  end
end
