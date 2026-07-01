class CreateReorderRules < ActiveRecord::Migration[8.1]
  def change
    create_table :reorder_rules do |t|
      t.references :inventory_item, null: false, foreign_key: { on_delete: :cascade }
      t.references :supplier,       null: true,  foreign_key: { on_delete: :nullify }
      t.integer :reorder_point,     null: false, default: 0
      t.integer :reorder_quantity,  null: false, default: 0
      t.boolean :auto_order,        null: false, default: false
      t.boolean :active,            null: false, default: true
      t.datetime :last_triggered_at
      t.timestamps
    end

    add_index :reorder_rules, :inventory_item_id, unique: true,
              name: "index_reorder_rules_on_inventory_item"
    add_index :reorder_rules, [:active, :auto_order],
              name: "index_reorder_rules_on_active_auto_order"

    add_check_constraint :reorder_rules, "reorder_point >= 0",
                         name: "chk_reorder_rules_point"
    add_check_constraint :reorder_rules, "reorder_quantity > 0",
                         name: "chk_reorder_rules_quantity"
  end
end
