# Polymorphic so any future entity (User, Company, Warehouse, ServiceCenter) can
# have addresses without adding a FK column to this table each time.
class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      # Polymorphic reference — the index is composite on (type, id) for fast lookups
      t.references :addressable, polymorphic: true, null: false, index: true

      # Human label e.g. "Head Office", "Warehouse B" — nullable
      t.string :label

      # Controlled vocabulary enforced by DB check: billing|shipping|default|other
      t.string :address_type, null: false, default: "default"

      # Street lines — line2 is nullable (apartment/suite is optional)
      t.string :line1,       null: false
      t.string :line2

      t.string :city,        null: false
      t.string :state,       null: false
      t.string :postal_code, null: false

      # ISO 3166-1 alpha-2 — 2 chars only, enforced by CHECK constraint below
      t.string :country_code, null: false, default: "US", limit: 2

      # Decimal precision suitable for GPS coordinates
      t.decimal :latitude,  precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8

      # Only one primary address per owner is enforced in the model, not the DB,
      # because a partial unique index across a polymorphic pair is complex.
      t.boolean :is_primary, null: false, default: false

      t.timestamps
    end

    # address_type must be one of the four known values
    add_check_constraint :addresses,
      "address_type IN ('billing', 'shipping', 'default', 'other')",
      name: "chk_addresses_address_type"

    # country_code must be exactly 2 uppercase chars
    add_check_constraint :addresses,
      "country_code ~ '^[A-Z]{2}$'",
      name: "chk_addresses_country_code"

    # Fast lookup of all primary addresses for a given owner
    add_index :addresses, [ :addressable_type, :addressable_id, :is_primary ],
              name: "index_addresses_on_addressable_and_primary"
  end
end
