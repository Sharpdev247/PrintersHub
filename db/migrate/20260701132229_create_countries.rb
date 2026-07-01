# Master reference table for countries.
# iso2/iso3 are ISO 3166-1 standards — globally unique by definition.
# Extra fields (continent, locale_code, timezone, etc.) cost nothing now and
# save a painful large-table migration when the Notifications/Analytics modules need them.
class CreateCountries < ActiveRecord::Migration[8.1]
  CONTINENTS = %w[Africa Antarctica Asia Europe North\ America Oceania South\ America].freeze

  def change
    create_table :countries do |t|
      t.string  :name,            null: false
      t.string  :iso2,            null: false, limit: 2   # ISO 3166-1 alpha-2
      t.string  :iso3,            null: false, limit: 3   # ISO 3166-1 alpha-3
      t.string  :phone_code                               # e.g. "+92"
      t.string  :currency_code,   limit: 3                # ISO 4217 e.g. "PKR"
      t.string  :currency_symbol                          # e.g. "₨"
      t.string  :continent
      t.string  :locale_code                              # e.g. "en-PK"
      t.string  :flag_emoji,      limit: 8                # e.g. "🇵🇰" (2 UTF-8 chars)
      t.string  :timezone                                 # e.g. "Asia/Karachi"
      t.integer :display_order,   null: false, default: 999
      t.boolean :active,          null: false, default: true

      t.timestamps
    end

    # Globally unique — ISO standards guarantee this
    add_index :countries, :name,  unique: true
    add_index :countries, :iso2,  unique: true
    add_index :countries, :iso3,  unique: true
    add_index :countries, :active
    add_index :countries, :display_order
    add_index :countries, :continent

    # iso2 must be exactly 2 uppercase letters
    add_check_constraint :countries,
      "iso2 ~ '^[A-Z]{2}$'",
      name: "chk_countries_iso2_format"

    # iso3 must be exactly 3 uppercase letters
    add_check_constraint :countries,
      "iso3 ~ '^[A-Z]{3}$'",
      name: "chk_countries_iso3_format"

    # continent must be one of the 7 recognised values (or NULL for territories/special cases)
    add_check_constraint :countries,
      "continent IS NULL OR continent IN ('Africa', 'Antarctica', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')",
      name: "chk_countries_continent"
  end
end
