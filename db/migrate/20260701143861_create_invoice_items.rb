# InvoiceItems — line items on an invoice.
#
# description — snapshot of what was billed (plan name, feature, etc.)
# unit_price × quantity = amount (enforced at model layer; stored as snapshot)
#
# FK: invoice → CASCADE : deleting an invoice removes its line items
class CreateInvoiceItems < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: { on_delete: :cascade }
      t.string  :description, null: false
      t.integer :quantity,    null: false, default: 1
      t.decimal :unit_price,  null: false, precision: 12, scale: 2
      t.decimal :amount,      null: false, precision: 12, scale: 2
      t.string  :currency,    null: false, default: "USD", limit: 3
      t.timestamps
    end

    add_check_constraint :invoice_items, "quantity > 0",
                         name: "chk_invoice_items_quantity"
    add_check_constraint :invoice_items, "unit_price >= 0",
                         name: "chk_invoice_items_unit_price"
    add_check_constraint :invoice_items, "amount >= 0",
                         name: "chk_invoice_items_amount"
    add_check_constraint :invoice_items, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_invoice_items_currency"
  end
end
