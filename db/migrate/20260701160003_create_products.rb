class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :account,       null: false, foreign_key: { on_delete: :restrict }
      t.references :brand,         null: true,  foreign_key: { on_delete: :nullify }
      t.references :category,      null: true,  foreign_key: { on_delete: :nullify }
      t.references :printer_model, null: true,  foreign_key: { on_delete: :nullify }
      t.string  :name,          null: false, limit: 255
      t.string  :sku,           null: false, limit: 100
      t.string  :barcode,       limit: 100
      t.string  :barcode_type,  limit: 20, default: "EAN13"
      t.text    :description
      t.integer :status,        null: false, default: 0
      t.decimal :base_cost,     precision: 12, scale: 2
      t.string  :cost_currency, limit: 3, default: "USD"
      t.decimal :weight,        precision: 10, scale: 3
      t.string  :weight_unit,   limit: 5, default: "kg"
      t.decimal :length,        precision: 10, scale: 3
      t.decimal :width,         precision: 10, scale: 3
      t.decimal :height,        precision: 10, scale: 3
      t.string  :dimension_unit, limit: 5, default: "cm"
      t.boolean :has_variants,  null: false, default: false
      t.boolean :track_inventory, null: false, default: true
      t.jsonb   :metadata
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :products, [:account_id, :sku], unique: true,
              name: "index_products_on_account_sku"
    add_index :products, :barcode,       name: "index_products_on_barcode"
    add_index :products, :status,        name: "index_products_on_status"
    add_index :products, :discarded_at,  name: "index_products_on_discarded_at"
    add_index :products, :name,          name: "index_products_on_name"

    add_check_constraint :products, "base_cost IS NULL OR base_cost >= 0",
                         name: "chk_products_base_cost"
    add_check_constraint :products, "weight IS NULL OR weight > 0",
                         name: "chk_products_weight"
    add_check_constraint :products, "cost_currency ~ '^[A-Z]{3}$'",
                         name: "chk_products_cost_currency"
    add_check_constraint :products, "weight_unit IN ('kg','lb','oz','g')",
                         name: "chk_products_weight_unit"
    add_check_constraint :products, "dimension_unit IN ('cm','in','mm')",
                         name: "chk_products_dimension_unit"
    add_check_constraint :products, "barcode_type IN ('EAN13','EAN8','UPC','ISBN','QR','CODE128','CODE39')",
                         name: "chk_products_barcode_type"
  end
end
