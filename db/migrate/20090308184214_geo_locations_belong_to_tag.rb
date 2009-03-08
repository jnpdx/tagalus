class GeoLocationsBelongToTag < ActiveRecord::Migration
  def self.up
    add_column :geo_locations, :tag_id, :integer
  end

  def self.down
    remove_column :geo_locations, :tag_id
  end
end
