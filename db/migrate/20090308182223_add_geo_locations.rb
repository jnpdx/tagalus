class AddGeoLocations < ActiveRecord::Migration
  def self.up
    create_table :geo_locations do |t|
      t.float :latitude
      t.float :longitude
      t.float :altitude
      t.float :accuracy
      t.float :altitude_accuracy
      t.float :heading
      t.float :speed

      t.timestamps
    end
  end

  def self.down
    drop_table :geo_locations
  end
end
