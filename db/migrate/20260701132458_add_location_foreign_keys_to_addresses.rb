# Dual-track address normalization.
#
# We ADD FK columns without removing the existing string columns (city, state,
# country_code). This dual-track design handles:
#   1. External API responses that return plain-text locations
#   2. Addresses that predate the country/state/city tables
#   3. Cities/states not yet in our reference data
#
# The NOT NULL on city, state, country_code is relaxed because a valid address
# can now express its location via FKs alone.
class AddLocationForeignKeysToAddresses < ActiveRecord::Migration[8.1]
  def up
    # Add nullable FK columns — nullable by design (see comment above)
    add_column :addresses, :country_id, :bigint
    add_column :addresses, :state_id,   :bigint
    add_column :addresses, :city_id,    :bigint

    # Indexes for FK lookups (joins and WHERE country_id = X)
    add_index :addresses, :country_id, where: "country_id IS NOT NULL"
    add_index :addresses, :state_id,   where: "state_id IS NOT NULL"
    add_index :addresses, :city_id,    where: "city_id IS NOT NULL"

    # FK constraints: RESTRICT so reference data cannot be deleted while addresses point to it
    add_foreign_key :addresses, :countries, column: :country_id, on_delete: :restrict
    add_foreign_key :addresses, :states,    column: :state_id,   on_delete: :restrict
    add_foreign_key :addresses, :cities,    column: :city_id,    on_delete: :restrict

    # Relax NOT NULL on legacy string columns — they are now optional fallbacks
    change_column_null :addresses, :city,  true
    change_column_null :addresses, :state, true
    change_column_null :addresses, :country_code, true

    # Update the country_code CHECK constraint to allow NULL
    remove_check_constraint :addresses, name: "chk_addresses_country_code"
    add_check_constraint :addresses,
      "country_code IS NULL OR country_code ~ '^[A-Z]{2}$'",
      name: "chk_addresses_country_code"

    # Require that at least one location reference exists (FK or legacy string)
    add_check_constraint :addresses,
      "country_id IS NOT NULL OR country_code IS NOT NULL",
      name: "chk_addresses_has_country"
  end

  def down
    remove_check_constraint :addresses, name: "chk_addresses_has_country"
    remove_check_constraint :addresses, name: "chk_addresses_country_code"
    add_check_constraint :addresses,
      "country_code ~ '^[A-Z]{2}$'",
      name: "chk_addresses_country_code"

    change_column_null :addresses, :city,         false
    change_column_null :addresses, :state,        false
    change_column_null :addresses, :country_code, false

    remove_foreign_key :addresses, column: :city_id
    remove_foreign_key :addresses, column: :state_id
    remove_foreign_key :addresses, column: :country_id

    remove_index  :addresses, column: :city_id,    if_exists: true
    remove_index  :addresses, column: :state_id,   if_exists: true
    remove_index  :addresses, column: :country_id, if_exists: true

    remove_column :addresses, :city_id
    remove_column :addresses, :state_id
    remove_column :addresses, :country_id
  end
end
