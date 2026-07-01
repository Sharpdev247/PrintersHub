# Cities within a state. latitude/longitude store the city centroid so that
# warehouses and service centers inherit a default coordinate without geocoding.
# RESTRICT on state delete: cannot delete a state that still has cities.
class CreateCities < ActiveRecord::Migration[8.1]
  def change
    create_table :cities do |t|
      t.references :state, null: false, foreign_key: { on_delete: :restrict }
      t.string  :name,      null: false
      # City centroid — precision matches the Address model
      t.decimal :latitude,  precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8

      t.timestamps
    end

    # "Lahore" is unique within Punjab — but another state could have a Lahore
    add_index :cities, [ :state_id, :name ], unique: true, name: "index_cities_on_state_and_name"

    # Supports city-name autocomplete search across all cities regardless of state
    add_index :cities, :name

    # Partial index on coordinates — only rows that have been geocoded are indexed
    add_index :cities, [ :latitude, :longitude ],
              where: "latitude IS NOT NULL AND longitude IS NOT NULL",
              name: "index_cities_on_coordinates"
  end
end
