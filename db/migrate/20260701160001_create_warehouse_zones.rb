class CreateWarehouseZones < ActiveRecord::Migration[8.1]
  def change
    create_table :warehouse_zones do |t|
      t.references :warehouse, null: false, foreign_key: { on_delete: :cascade }
      t.string :name,        null: false, limit: 100
      t.string :code,        null: false, limit: 20
      t.string :description, limit: 255
      t.string :zone_type,   null: false, default: "storage", limit: 30
      t.boolean :active,     null: false, default: true
      t.timestamps
    end

    add_index :warehouse_zones, [:warehouse_id, :code], unique: true,
              name: "index_warehouse_zones_on_warehouse_code"
    add_check_constraint :warehouse_zones,
                         "zone_type IN ('storage','receiving','dispatch','quarantine','returns')",
                         name: "chk_warehouse_zones_zone_type"
  end
end
