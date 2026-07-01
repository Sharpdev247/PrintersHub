class CreateInventoryCountItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_count_items do |t|
      t.references :inventory_count, null: false, foreign_key: { on_delete: :cascade }
      t.references :inventory_item,  null: false, foreign_key: { on_delete: :restrict }
      t.integer :expected_quantity,  null: false, default: 0
      t.integer :actual_quantity
      t.integer :variance
      t.boolean :counted,            null: false, default: false
      t.text    :notes
      t.bigint  :counted_by_id
      t.datetime :counted_at
      t.timestamps
    end

    add_index :inventory_count_items, [:inventory_count_id, :inventory_item_id], unique: true,
              name: "index_inventory_count_items_on_count_item"
    add_index :inventory_count_items, :counted,
              name: "index_inventory_count_items_on_counted"

    add_check_constraint :inventory_count_items, "expected_quantity >= 0",
                         name: "chk_inventory_count_items_expected"
    add_check_constraint :inventory_count_items,
                         "actual_quantity IS NULL OR actual_quantity >= 0",
                         name: "chk_inventory_count_items_actual"
  end
end
