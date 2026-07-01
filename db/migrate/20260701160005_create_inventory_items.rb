class CreateInventoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_items do |t|
      t.references :product_variant, null: false, foreign_key: { on_delete: :restrict }
      t.references :warehouse,       null: false, foreign_key: { on_delete: :restrict }
      t.references :warehouse_zone,  null: true,  foreign_key: { on_delete: :nullify }
      t.string  :location_code,       limit: 50
      t.integer :quantity_on_hand,    null: false, default: 0
      t.integer :reserved_quantity,   null: false, default: 0
      t.integer :reorder_point,       default: 0
      t.integer :reorder_quantity,    default: 0
      t.integer :minimum_quantity,    default: 0
      t.integer :maximum_quantity
      t.decimal :unit_cost,           precision: 12, scale: 2
      t.string  :cost_currency,       limit: 3, default: "USD"
      t.boolean :allow_backorders,    null: false, default: false
      t.boolean :active,              null: false, default: true
      t.jsonb   :metadata
      t.timestamps
    end

    add_index :inventory_items, [:product_variant_id, :warehouse_id], unique: true,
              name: "index_inventory_items_on_variant_warehouse"
    add_index :inventory_items, :quantity_on_hand,
              name: "index_inventory_items_on_quantity_on_hand"
    add_index :inventory_items, :location_code,
              name: "index_inventory_items_on_location_code"

    add_check_constraint :inventory_items, "quantity_on_hand >= 0 OR allow_backorders = true",
                         name: "chk_inventory_items_quantity"
    add_check_constraint :inventory_items, "reserved_quantity >= 0",
                         name: "chk_inventory_items_reserved"
    add_check_constraint :inventory_items, "reserved_quantity <= quantity_on_hand OR allow_backorders = true",
                         name: "chk_inventory_items_reserved_lte_on_hand"
    add_check_constraint :inventory_items, "reorder_point >= 0",
                         name: "chk_inventory_items_reorder_point"
    add_check_constraint :inventory_items, "cost_currency ~ '^[A-Z]{3}$'",
                         name: "chk_inventory_items_cost_currency"
  end
end
