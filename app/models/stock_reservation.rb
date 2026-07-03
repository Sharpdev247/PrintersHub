class StockReservation < ApplicationRecord
  audited

  belongs_to :inventory_item
  belongs_to :order_item

  enum :status, {
    pending:   0,
    confirmed: 1,
    shipped:   2,
    released:  3,
    expired:   4
  }, prefix: true

  validates :quantity, numericality: { greater_than: 0 }

  scope :active,   -> { where(status: [ :pending, :confirmed ]) }
  scope :expired,  -> { where("expires_at < ? AND status IN (0,1)", Time.current) }

  def release!
    inventory_item.release_reservation!(self)
  end
end
