class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: { on_delete: :cascade }
      t.string  :name,         null: false, limit: 255
      t.string  :variant_sku,  null: false, limit: 100
      t.string  :barcode,      limit: 100
      t.jsonb   :options_data,  null: false, default: {}
      t.decimal :cost_override,  precision: 12, scale: 2
      t.decimal :weight_override, precision: 10, scale: 3
      t.integer :position,     null: false, default: 0
      t.boolean :active,       null: false, default: true
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :product_variants, [ :product_id, :variant_sku ], unique: true,
              name: "index_product_variants_on_product_sku"
    add_index :product_variants, :barcode, name: "index_product_variants_on_barcode"
    add_index :product_variants, :discarded_at, name: "index_product_variants_on_discarded_at"
    add_index :product_variants, [ :product_id, :position ],
              name: "index_product_variants_on_product_position"

    add_check_constraint :product_variants,
                         "cost_override IS NULL OR cost_override >= 0",
                         name: "chk_product_variants_cost"
    add_check_constraint :product_variants,
                         "weight_override IS NULL OR weight_override > 0",
                         name: "chk_product_variants_weight"
  end
end
