class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :listing,        optional: true
  belongs_to :seller_account, class_name: "Account", optional: true
  has_many   :shipment_items, dependent: :restrict_with_error
  has_many   :shipments,      through: :shipment_items

  validates :quantity,         numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price,       numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount,       numericality: { greater_than_or_equal_to: 0 }
  validates :discount_amount,  numericality: { greater_than_or_equal_to: 0 }
  validates :total,            numericality: { greater_than_or_equal_to: 0 }
  validates :currency,         format: { with: /\A[A-Z]{3}\z/ }

  before_validation :calculate_total
  before_create     :capture_listing_snapshot

  def line_subtotal
    unit_price * quantity
  end

  def line_total
    [(line_subtotal + tax_amount - discount_amount), 0].max
  end

  def quantity_shipped
    shipment_items.sum(:quantity)
  end

  def quantity_remaining
    quantity - quantity_shipped
  end

  def fully_shipped?
    quantity_shipped >= quantity
  end

  def self.from_cart_item(cart_item)
    new(
      listing:        cart_item.listing,
      seller_account: cart_item.listing&.account,
      quantity:       cart_item.quantity,
      unit_price:     cart_item.unit_price,
      currency:       cart_item.currency
    )
  end

  private

  def calculate_total
    self.total = [((unit_price.to_d * quantity.to_i) + tax_amount.to_d - discount_amount.to_d), 0].max
  end

  def capture_listing_snapshot
    return if listing_snapshot.present? || listing.nil?
    self.listing_snapshot = {
      id:          listing.id,
      title:       listing.title,
      price:       listing.price.to_s,
      currency:    listing.currency,
      condition:   listing.condition,
      slug:        listing.slug,
      brand:       listing.brand&.name,
      category:    listing.category&.name,
      captured_at: Time.current.iso8601
    }
    self.seller_account ||= listing.account
  end
end
