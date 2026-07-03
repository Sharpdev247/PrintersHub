class CreateStockTransferItems < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_transfer_items do |t|
      t.references :stock_transfer,  null: false, foreign_key: { on_delete: :cascade }
      t.references :inventory_item,  null: false, foreign_key: { on_delete: :restrict }
      t.integer :quantity_requested, null: false
      t.integer :quantity_shipped,   null: false, default: 0
      t.integer :quantity_received,  null: false, default: 0
      t.text    :notes
      t.timestamps
    end

    add_index :stock_transfer_items, [ :stock_transfer_id, :inventory_item_id ], unique: true,
              name: "index_stock_transfer_items_on_transfer_item"
    add_check_constraint :stock_transfer_items, "quantity_requested > 0",
                         name: "chk_stock_transfer_items_requested"
    add_check_constraint :stock_transfer_items, "quantity_shipped >= 0",
                         name: "chk_stock_transfer_items_shipped"
    add_check_constraint :stock_transfer_items, "quantity_received >= 0",
                         name: "chk_stock_transfer_items_received"
  end
end
