require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def pending_order   = orders(:pending_order)
  def completed_order = orders(:completed_order)
  def seller_account  = accounts(:seller_account)
  def buyer_account   = accounts(:buyer_account)
  def buyer           = users(:buyer)

  def valid_attrs(overrides = {})
    {
      buyer_account:  buyer_account,
      seller_account: seller_account,
      created_by:     buyer,
      currency:       "PKR",
      subtotal:       10_000,
      tax_amount:     0,
      shipping_amount: 500,
      discount_amount: 0,
      total:          10_500,
      status:         :pending_payment
    }.merge(overrides)
  end

  # ── Validity ──────────────────────────────────────────────────────────────

  test "fixture pending_order is valid" do
    assert pending_order.valid?
  end

  test "invalid when buyer and seller are the same account" do
    o = Order.new(valid_attrs(seller_account: buyer_account))
    assert_not o.valid?
    assert o.errors[:base].any?
  end

  test "invalid with negative total" do
    o = Order.new(valid_attrs(total: -1))
    assert_not o.valid?
    assert o.errors[:total].any?
  end

  test "invalid with malformed currency" do
    o = Order.new(valid_attrs(currency: "dollars"))
    assert_not o.valid?
    assert o.errors[:currency].any?
  end

  test "order_number is auto-generated before validation" do
    o = Order.new(valid_attrs)
    o.valid?
    assert_not_nil o.order_number
  end

  # ── Scopes ────────────────────────────────────────────────────────────────

  test "for_buyer returns orders for the buyer account" do
    results = Order.for_buyer(buyer_account)
    assert results.include?(pending_order)
    assert results.none? { |o| o.buyer_account_id != buyer_account.id }
  end

  test "for_seller returns orders for the seller account" do
    results = Order.for_seller(seller_account)
    assert results.include?(pending_order)
  end

  test "paid scope returns only orders with paid_at set" do
    assert Order.paid.all? { |o| o.paid_at.present? }
    assert_not Order.paid.include?(pending_order)
    assert Order.paid.include?(completed_order)
  end

  # ── cancellable? ──────────────────────────────────────────────────────────

  test "cancellable? is true for pending_payment" do
    assert pending_order.cancellable?
  end

  test "cancellable? is false for completed" do
    assert_not completed_order.cancellable?
  end

  # ── Enums ─────────────────────────────────────────────────────────────────

  test "status enum has draft and completed" do
    assert Order.statuses.key?("draft")
    assert Order.statuses.key?("completed")
    assert Order.statuses.key?("cancelled")
  end

  # ── for_account scope (buyer OR seller) ───────────────────────────────────

  test "for_account returns orders where account is buyer or seller" do
    results = Order.for_account(buyer_account)
    assert results.include?(pending_order)
  end
end
