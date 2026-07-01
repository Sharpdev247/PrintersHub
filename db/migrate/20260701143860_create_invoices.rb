# Invoices — billing documents sent to accounts.
#
# status enum: 0=draft, 1=open, 2=paid, 3=void, 4=uncollectible
#
# invoice_number — human-readable sequential number (e.g. "INV-2026-00001")
#   generated at model layer, stored for display and accounting.
#
# subtotal / discount_amount / tax_amount / total — all stored as snapshots.
#   Never re-calculate from invoice_items after the invoice is paid; these
#   are the legal amounts at the time of billing.
#
# provider_invoice_id — Stripe/Paddle invoice ID for reconciliation.
# metadata JSONB — provider-specific data, tax breakdown, etc.
#
# FK strategies:
#   account → RESTRICT : preserve billing history even if account is deactivated
class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :account, null: false, foreign_key: { on_delete: :restrict }
      t.integer :status,          null: false, default: 0
      t.string  :invoice_number,  null: false
      t.decimal :subtotal,        null: false, default: 0, precision: 12, scale: 2
      t.decimal :discount_amount, null: false, default: 0, precision: 12, scale: 2
      t.decimal :tax_amount,      null: false, default: 0, precision: 12, scale: 2
      t.decimal :total,           null: false, default: 0, precision: 12, scale: 2
      t.string  :currency,        null: false, default: "USD", limit: 3
      t.text    :notes
      t.datetime :due_at
      t.datetime :paid_at
      t.string  :provider_invoice_id
      t.jsonb   :metadata,        null: false, default: {}
      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true,
              name: "index_invoices_on_invoice_number"
    add_index :invoices, [:account_id, :status],
              name: "index_invoices_on_account_and_status"
    add_index :invoices, :due_at,
              where: "due_at IS NOT NULL AND status IN (1)",
              name: "index_invoices_on_due_at_open"
    add_index :invoices, :provider_invoice_id,
              where: "provider_invoice_id IS NOT NULL",
              unique: true,
              name: "index_invoices_on_provider_invoice_id"

    add_check_constraint :invoices, "subtotal >= 0",
                         name: "chk_invoices_subtotal"
    add_check_constraint :invoices, "discount_amount >= 0",
                         name: "chk_invoices_discount"
    add_check_constraint :invoices, "tax_amount >= 0",
                         name: "chk_invoices_tax"
    add_check_constraint :invoices, "total >= 0",
                         name: "chk_invoices_total"
    add_check_constraint :invoices, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_invoices_currency"
  end
end
