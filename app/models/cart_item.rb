class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :listing
  belongs_to :added_by, class_name: "User", optional: true

  validates :quantity,   numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :currency,   format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" }
  validates :listing_id, uniqueness: { scope: :cart_id, message: "is already in the cart" }
  validate  :listing_is_available

  def subtotal
    unit_price * quantity
  end

  def refresh_price!
    update!(unit_price: listing.price, currency: listing.currency)
  end

  private

  def listing_is_available
    return unless listing
    unless listing.status_published?
      errors.add(:listing, "is no longer available")
    end
  end
end
