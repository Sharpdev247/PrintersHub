class StockAdjustment < ApplicationRecord
  audited

  belongs_to :inventory_item
  belongs_to :account
  belongs_to :adjusted_by, class_name: "User", foreign_key: :adjusted_by_id

  enum :reason_code, {
    cycle_count:        0,
    physical_count:     1,
    damage:             2,
    theft:              3,
    expiry:             4,
    supplier_error:     5,
    system_correction:  6,
    return_processing:  7,
    other:              8
  }, prefix: true

  validates :quantity_change, numericality: { other_than: 0 }
  validates :adjusted_at,     presence: true

  scope :recent, -> { order(adjusted_at: :desc) }
end
