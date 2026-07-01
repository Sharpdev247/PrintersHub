class InventoryCountItem < ApplicationRecord
  belongs_to :inventory_count
  belongs_to :inventory_item
  belongs_to :counted_by, class_name: "User", foreign_key: :counted_by_id, optional: true

  validates :expected_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :actual_quantity,   numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :counted,   -> { where(counted: true) }
  scope :uncounted, -> { where(counted: false) }
  scope :with_variance, -> { where("variance != 0") }

  def record_count!(actual_qty, user = nil)
    update!(
      actual_quantity: actual_qty,
      variance:        actual_qty - expected_quantity,
      counted:         true,
      counted_by_id:   user&.id,
      counted_at:      Time.current
    )
  end
end
