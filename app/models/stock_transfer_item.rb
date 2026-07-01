class StockTransferItem < ApplicationRecord
  audited

  belongs_to :stock_transfer
  belongs_to :inventory_item

  validates :quantity_requested, numericality: { greater_than: 0 }
  validates :quantity_shipped,   numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_received,  numericality: { greater_than_or_equal_to: 0 }
  validate  :received_lte_shipped

  delegate :product_variant, to: :inventory_item

  def variance
    return nil unless stock_transfer.status_received?
    quantity_received - quantity_shipped
  end

  private

  def received_lte_shipped
    return unless quantity_received > quantity_shipped
    errors.add(:quantity_received, "cannot exceed quantity shipped")
  end
end
