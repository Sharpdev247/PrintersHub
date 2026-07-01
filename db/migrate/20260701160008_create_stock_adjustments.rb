class CreateStockAdjustments < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_adjustments do |t|
      t.references :inventory_item, null: false, foreign_key: { on_delete: :restrict }
      t.references :account,        null: false, foreign_key: { on_delete: :restrict }
      t.bigint  :adjusted_by_id,    null: false
      t.integer :quantity_change,   null: false
      t.integer :reason_code,       null: false, default: 0
      t.text    :notes
      t.string  :reference_number,  limit: 100
      t.datetime :adjusted_at,      null: false
      t.timestamps
    end

    add_index :stock_adjustments, :reason_code,
              name: "index_stock_adjustments_on_reason_code"
    add_index :stock_adjustments, :adjusted_at,
              name: "index_stock_adjustments_on_adjusted_at"

    add_check_constraint :stock_adjustments, "quantity_change != 0",
                         name: "chk_stock_adjustments_nonzero"
    add_check_constraint :stock_adjustments,
                         "reason_code IN (0,1,2,3,4,5,6,7,8)",
                         name: "chk_stock_adjustments_reason_code"
  end
end
