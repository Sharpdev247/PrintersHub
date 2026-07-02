# Generates (or returns existing) an order invoice for a given order.
#
# Usage:
#   invoice = InvoiceGenerator.call(order)
#
class InvoiceGenerator
  def self.call(order)
    new(order).call
  end

  def initialize(order)
    @order = order
  end

  def call
    existing = Invoice.find_by(order: @order)
    return existing if existing

    Invoice.transaction do
      invoice = Invoice.create!(
        account:        @order.seller_account,
        buyer_account:  @order.buyer_account,
        order:          @order,
        invoice_type:   "order",
        status:         @order.paid_at ? :paid : :open,
        currency:       @order.currency,
        subtotal:       @order.subtotal,
        tax_amount:     @order.tax_amount,
        discount_amount: @order.discount_amount,
        total:          @order.total,
        paid_at:        @order.paid_at,
        due_at:         @order.created_at + 7.days,
        notes:          "Invoice for order #{@order.order_number}"
      )

      @order.order_items.each do |item|
        snap  = item.listing_snapshot || {}
        title = snap["title"] || item.listing&.title || "Item"
        invoice.invoice_items.create!(
          description: title,
          quantity:    item.quantity,
          unit_price:  item.unit_price,
          amount:      item.total,
          currency:    item.currency
        )
      end

      invoice
    end
  end
end
