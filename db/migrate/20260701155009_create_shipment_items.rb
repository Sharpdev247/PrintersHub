# ShipmentItems — join between a Shipment and OrderItems.
# Supports partial shipments: one order_item may be split across multiple shipments.
# FK: shipment → CASCADE (deleting shipment removes its items)
# FK: order_item → RESTRICT (can't delete order_item with shipment items)
class CreateShipmentItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shipment_items do |t|
      t.references :shipment,   null: false, foreign_key: { on_delete: :cascade }
      t.references :order_item, null: false, foreign_key: { on_delete: :restrict }
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end

    add_index :shipment_items, [:shipment_id, :order_item_id],
              unique: true,
              name: "index_shipment_items_on_shipment_and_order_item"

    add_check_constraint :shipment_items, "quantity > 0", name: "chk_shipment_items_quantity"
  end
end
