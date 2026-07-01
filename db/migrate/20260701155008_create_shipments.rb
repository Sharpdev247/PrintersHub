# Shipments — one per fulfillment batch from a seller.
# Multiple shipments per order are supported (partial fulfillment).
# FK: order → RESTRICT (can't delete order with shipments)
# FK: account → RESTRICT (can't delete account with shipments)
# status: 0=pending, 1=preparing, 2=picked_up, 3=in_transit, 4=out_for_delivery,
#         5=delivered, 6=attempted_delivery, 7=exception, 8=returned
class CreateShipments < ActiveRecord::Migration[8.1]
  def change
    create_table :shipments do |t|
      t.references :order,   null: false, foreign_key: { on_delete: :restrict }
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.string  :tracking_number, limit: 100
      t.string  :carrier,         limit: 100
      t.integer :status,          null: false, default: 0
      t.decimal :weight,          precision: 10, scale: 3
      t.string  :weight_unit,     limit: 5, default: "kg"
      t.decimal :shipping_cost,   precision: 12, scale: 2
      t.string  :currency,        limit: 3, default: "USD"
      t.text    :notes
      t.datetime :shipped_at
      t.datetime :estimated_delivery_at
      t.datetime :delivered_at
      t.jsonb    :metadata
      t.timestamps
    end

    add_index :shipments, :tracking_number,
              unique: true,
              where: "tracking_number IS NOT NULL",
              name: "index_shipments_on_tracking_number"
    add_index :shipments, [:account_id, :status], name: "index_shipments_on_account_and_status"
    add_index :shipments, :status,                name: "index_shipments_on_status"
    # t.references :order and :account above auto-create index_shipments_on_order_id
    # and index_shipments_on_account_id — no explicit add_index needed for those

    add_check_constraint :shipments, "weight IS NULL OR weight > 0",
                         name: "chk_shipments_weight"
    add_check_constraint :shipments, "shipping_cost IS NULL OR shipping_cost >= 0",
                         name: "chk_shipments_shipping_cost"
    add_check_constraint :shipments, "weight_unit IN ('kg', 'lb', 'oz', 'g')",
                         name: "chk_shipments_weight_unit"
  end
end
