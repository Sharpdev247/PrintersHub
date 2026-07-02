class AddOrderToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_reference :invoices, :order,         null: true, foreign_key: true
    add_reference :invoices, :buyer_account, null: true, foreign_key: { to_table: :accounts }
    add_column    :invoices, :invoice_type,  :string, limit: 20, default: "subscription"
    add_index     :invoices, :invoice_type
  end
end
