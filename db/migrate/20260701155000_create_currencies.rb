class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies do |t|
      t.string  :code,   null: false, limit: 3
      t.string  :name,   null: false
      t.string  :symbol, null: false, limit: 10
      t.decimal :exchange_rate, null: false, precision: 18, scale: 8, default: "1.0"
      t.datetime :exchange_rate_updated_at
      t.boolean :active,     null: false, default: true
      t.boolean :is_default, null: false, default: false
      t.timestamps
    end

    add_index :currencies, :code, unique: true, name: "index_currencies_on_code"
    add_index :currencies, :active, where: "active = true", name: "index_currencies_active"
    add_index :currencies, :is_default,
              unique: true,
              where: "is_default = true",
              name: "index_currencies_on_default_unique"

    add_check_constraint :currencies, "exchange_rate > 0",    name: "chk_currencies_exchange_rate"
    add_check_constraint :currencies, "code ~ '^[A-Z]{3}$'", name: "chk_currencies_code"
  end
end
