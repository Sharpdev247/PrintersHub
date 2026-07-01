class CreateTaxRates < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_rates do |t|
      t.string  :name,         null: false
      t.string  :country_code, null: false, limit: 2
      t.string  :state_code,   limit: 10
      t.integer :tax_type,     null: false, default: 0
      t.decimal :rate,         null: false, precision: 8, scale: 6
      t.boolean :active,       null: false, default: true
      t.text    :description
      t.timestamps
    end

    add_index :tax_rates, [:country_code, :state_code, :active],
              name: "index_tax_rates_on_country_state_active"
    add_index :tax_rates, [:country_code, :state_code, :tax_type],
              unique: true,
              where: "active = true",
              name: "index_tax_rates_unique_active"

    add_check_constraint :tax_rates, "rate >= 0 AND rate <= 1",       name: "chk_tax_rates_rate"
    add_check_constraint :tax_rates, "country_code ~ '^[A-Z]{2}$'",  name: "chk_tax_rates_country_code"
  end
end
