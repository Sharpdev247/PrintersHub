class CreateInventoryCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_counts do |t|
      t.references :account,   null: false, foreign_key: { on_delete: :restrict }
      t.references :warehouse, null: false, foreign_key: { on_delete: :restrict }
      t.string  :count_number, null: false, limit: 50
      t.integer :status,       null: false, default: 0
      t.string  :count_type,   null: false, default: "full", limit: 20
      t.text    :notes
      t.bigint  :created_by_id
      t.bigint  :approved_by_id
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :approved_at
      t.timestamps
    end

    add_index :inventory_counts, :count_number, unique: true,
              name: "index_inventory_counts_on_count_number"
    add_index :inventory_counts, [:account_id, :status],
              name: "index_inventory_counts_on_account_status"

    add_check_constraint :inventory_counts,
                         "count_type IN ('full','cycle','spot')",
                         name: "chk_inventory_counts_type"
    add_check_constraint :inventory_counts,
                         "status IN (0,1,2,3,4)",
                         name: "chk_inventory_counts_status"
  end
end
