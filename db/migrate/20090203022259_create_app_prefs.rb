class CreateAppPrefs < ActiveRecord::Migration
  def self.up
    create_table :app_prefs do |t|
      t.string :pref_key
      t.string :pref_val
      t.timestamps
    end
  end

  def self.down
    drop_table :app_prefs
  end
end
