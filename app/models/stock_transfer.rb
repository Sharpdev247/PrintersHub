class StockTransfer < ApplicationRecord
  audited

  belongs_to :account
  belongs_to :source_warehouse,      class_name: "Warehouse",
             foreign_key: :source_warehouse_id, inverse_of: :stock_transfers_out
  belongs_to :destination_warehouse, class_name: "Warehouse",
             foreign_key: :destination_warehouse_id, inverse_of: :stock_transfers_in
  belongs_to :created_by,  class_name: "User", foreign_key: :created_by_id,  optional: true
  belongs_to :approved_by, class_name: "User", foreign_key: :approved_by_id, optional: true

  has_many :stock_transfer_items, dependent: :destroy

  enum :status, {
    draft:      0,
    requested:  1,
    approved:   2,
    shipped:    3,
    received:   4,
    cancelled:  5
  }, prefix: true

  before_validation :generate_transfer_number, on: :create

  validates :transfer_number, presence: true, uniqueness: true
  validates :requested_at,    presence: true
  validate  :different_warehouses

  scope :recent,   -> { order(created_at: :desc) }
  scope :pending,  -> { where(status: [ :draft, :requested, :approved, :shipped ]) }

  def approve!(user)
    update!(status: :approved, approved_by: user, approved_at: Time.current)
  end

  def ship!(user = nil)
    transaction do
      update!(status: :shipped, shipped_at: Time.current)
      stock_transfer_items.each do |item|
        item.inventory_item.adjust!(
          quantity_change: -item.quantity_requested,
          reason_code:     :system_correction,
          notes:           "Transfer out: #{transfer_number}",
          performed_by:    user&.id
        )
        item.update!(quantity_shipped: item.quantity_requested)
      end
    end
  end

  def receive!(user = nil)
    transaction do
      update!(status: :received, received_at: Time.current)
      stock_transfer_items.each do |item|
        dest_item = InventoryItem.find_or_create_by!(
          product_variant: item.inventory_item.product_variant,
          warehouse:       destination_warehouse
        )
        dest_item.receive!(
          quantity:            item.quantity_shipped,
          lot_number:          nil,
          performed_by:        user&.id
        )
        item.update!(quantity_received: item.quantity_shipped)
      end
    end
  end

  private

  def generate_transfer_number
    return if transfer_number.present?
    year  = Time.current.year
    seq   = StockTransfer.where("transfer_number LIKE ?", "TRF-#{year}-%").count + 1
    self.transfer_number = "TRF-#{year}-#{seq.to_s.rjust(5, '0')}"
  end

  def different_warehouses
    if source_warehouse_id.present? && source_warehouse_id == destination_warehouse_id
      errors.add(:destination_warehouse, "must be different from source warehouse")
    end
  end
end
