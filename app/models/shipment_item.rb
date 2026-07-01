class ShipmentItem < ApplicationRecord
  belongs_to :shipment
  belongs_to :order_item

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validate  :quantity_does_not_exceed_remaining

  private

  def quantity_does_not_exceed_remaining
    return unless order_item && quantity
    already_shipped = order_item.shipment_items
                                .where.not(id: id)
                                .sum(:quantity)
    remaining = order_item.quantity - already_shipped
    if quantity > remaining
      errors.add(:quantity, "cannot exceed remaining unshipped quantity (#{remaining})")
    end
  end
end
