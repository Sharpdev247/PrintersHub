class InventoryTransaction < ApplicationRecord
  belongs_to :inventory_item
  belongs_to :account
  belongs_to :performed_by, class_name: "User", foreign_key: :performed_by_id, optional: true

  enum :transaction_type, {
    purchase:         0,
    sale:             1,
    reservation:      2,
    release:          3,
    shipment:         4,
    return:           5,
    transfer_in:      6,
    transfer_out:     7,
    adjustment:       8,
    count_correction: 9,
    damage:           10
  }, prefix: true

  enum :direction, {
    in:      0,
    out:     1,
    neutral: 2
  }, prefix: true

  INCREASING_TYPES = %w[purchase return transfer_in adjustment count_correction].freeze
  DECREASING_TYPES = %w[sale shipment transfer_out damage].freeze

  validates :quantity_change, numericality: { other_than: 0 }
  validates :performed_at,    presence: true
  validates :source, inclusion: { in: %w[system user webhook admin import] }
  validate  :ledger_balance_check

  scope :recent,          -> { order(performed_at: :desc) }
  scope :since,           ->(time) { where("performed_at >= ?", time) }
  scope :for_reference,   ->(type, id) { where(reference_type: type, reference_id: id) }
  scope :increasing,      -> { direction_in }
  scope :decreasing,      -> { direction_out }

  # Append-only — prevent updates
  before_update { raise ActiveRecord::ReadOnlyRecord, "InventoryTransaction is immutable" }
  before_destroy { raise ActiveRecord::ReadOnlyRecord, "InventoryTransaction cannot be deleted" }

  private

  def ledger_balance_check
    unless quantity_before + quantity_change == quantity_after
      errors.add(:base, "ledger balance violation: before(#{quantity_before}) + change(#{quantity_change}) != after(#{quantity_after})")
    end
  end
end
