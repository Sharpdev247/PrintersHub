class InventoryCount < ApplicationRecord
  audited

  belongs_to :account
  belongs_to :warehouse
  belongs_to :created_by,  class_name: "User", foreign_key: :created_by_id,  optional: true
  belongs_to :approved_by, class_name: "User", foreign_key: :approved_by_id, optional: true

  has_many :inventory_count_items, dependent: :destroy

  enum :status, {
    draft:       0,
    in_progress: 1,
    completed:   2,
    approved:    3,
    cancelled:   4
  }, prefix: true

  validates :count_number, presence: true, uniqueness: true
  validates :count_type,   inclusion: { in: %w[full cycle spot] }

  before_validation :generate_count_number, on: :create

  scope :recent, -> { order(created_at: :desc) }

  def start!
    snapshot_current_inventory!
    update!(status: :in_progress, started_at: Time.current)
  end

  def complete!(user = nil)
    transaction do
      update!(status: :completed, completed_at: Time.current)
    end
  end

  def approve!(user)
    transaction do
      apply_corrections!(user)
      update!(status: :approved, approved_by: user, approved_at: Time.current)
    end
  end

  def progress_percentage
    total   = inventory_count_items.count
    counted = inventory_count_items.where(counted: true).count
    total.zero? ? 0 : (counted.to_f / total * 100).round(1)
  end

  private

  def generate_count_number
    return if count_number.present?
    year = Time.current.year
    seq  = InventoryCount.where("count_number LIKE ?", "CNT-#{year}-%").count + 1
    self.count_number = "CNT-#{year}-#{seq.to_s.rjust(4, '0')}"
  end

  def snapshot_current_inventory!
    warehouse.inventory_items.active.each do |item|
      inventory_count_items.find_or_create_by!(inventory_item: item) do |ci|
        ci.expected_quantity = item.quantity_on_hand
      end
    end
  end

  def apply_corrections!(user)
    inventory_count_items.where(counted: true).each do |count_item|
      next if count_item.actual_quantity.nil?
      variance = count_item.actual_quantity - count_item.expected_quantity
      next if variance.zero?

      count_item.inventory_item.adjust!(
        quantity_change: variance,
        reason_code:     :physical_count,
        notes:           "Count #{count_number} correction",
        performed_by:    user&.id
      )
      count_item.update!(variance: variance)
    end
  end
end
