class CreateStockReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_reservations do |t|
      t.references :inventory_item, null: false, foreign_key: { on_delete: :restrict }
      t.references :order_item,     null: false, foreign_key: { on_delete: :cascade }
      t.integer :quantity,          null: false
      t.integer :status,            null: false, default: 0
      t.datetime :expires_at
      t.datetime :released_at
      t.timestamps
    end

    add_index :stock_reservations, [:order_item_id, :inventory_item_id], unique: true,
              name: "index_stock_reservations_on_order_item_inventory_item"
    add_index :stock_reservations, :status,
              name: "index_stock_reservations_on_status"
    add_index :stock_reservations, :expires_at,
              where: "expires_at IS NOT NULL",
              name: "index_stock_reservations_on_expires_at"

    add_check_constraint :stock_reservations, "quantity > 0",
                         name: "chk_stock_reservations_quantity"
  end
end
