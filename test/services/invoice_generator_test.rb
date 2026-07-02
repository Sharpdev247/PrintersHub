require "test_helper"

class InvoiceGeneratorTest < ActiveSupport::TestCase
  def pending_order   = orders(:pending_order)
  def completed_order = orders(:completed_order)

  # ── Idempotency ───────────────────────────────────────────────────────────

  test "calling twice returns the same invoice" do
    inv1 = InvoiceGenerator.call(pending_order)
    inv2 = InvoiceGenerator.call(pending_order)
    assert_equal inv1.id, inv2.id
  end

  # ── Invoice attributes ────────────────────────────────────────────────────

  test "creates an invoice with order invoice_type" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal "order", inv.invoice_type
  end

  test "sets status to open when order is not yet paid" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal "open", inv.status
  end

  test "sets status to paid when order has paid_at" do
    inv = InvoiceGenerator.call(completed_order)
    assert_equal "paid", inv.status
  end

  test "invoice total matches order total" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal pending_order.total, inv.total
  end

  test "invoice currency matches order currency" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal pending_order.currency, inv.currency
  end

  test "invoice seller account matches order seller account" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal pending_order.seller_account_id, inv.account_id
  end

  test "invoice buyer_account matches order buyer_account" do
    inv = InvoiceGenerator.call(pending_order)
    assert_equal pending_order.buyer_account_id, inv.buyer_account_id
  end
end
