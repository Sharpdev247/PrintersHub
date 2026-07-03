class CreatePurchaseOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order,   null: false, foreign_key: { on_delete: :cascade }
      t.references :product_variant,  null: false, foreign_key: { on_delete: :restrict }
      t.references :inventory_item,   null: true,  foreign_key: { on_delete: :nullify }
      t.integer :quantity_ordered,    null: false
      t.integer :quantity_received,   null: false, default: 0
      t.decimal :unit_cost,           null: false, precision: 12, scale: 2
      t.decimal :total_cost,          null: false, precision: 12, scale: 2
      t.text    :notes
      t.datetime :received_at
      t.timestamps
    end

    add_index :purchase_order_items, [ :purchase_order_id, :product_variant_id ], unique: true,
              name: "index_po_items_on_po_variant"
    add_check_constraint :purchase_order_items, "quantity_ordered > 0",
                         name: "chk_po_items_quantity_ordered"
    add_check_constraint :purchase_order_items, "quantity_received >= 0",
                         name: "chk_po_items_quantity_received"
    add_check_constraint :purchase_order_items, "quantity_received <= quantity_ordered",
                         name: "chk_po_items_received_lte_ordered"
    add_check_constraint :purchase_order_items, "unit_cost >= 0",
                         name: "chk_po_items_unit_cost"
    add_check_constraint :purchase_order_items, "total_cost >= 0",
                         name: "chk_po_items_total_cost"
  end
end
