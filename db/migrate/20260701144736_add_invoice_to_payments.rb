class AddInvoiceToPayments < ActiveRecord::Migration[8.1]
  def change
    add_reference :payments, :invoice, null: true, foreign_key: { on_delete: :nullify }
  end
end
