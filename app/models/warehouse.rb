class Warehouse < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account

  has_many :warehouse_zones,       dependent: :destroy
  has_many :inventory_items,       dependent: :restrict_with_error
  has_many :stock_transfers_out,   class_name: "StockTransfer",
           foreign_key: :source_warehouse_id, dependent: :restrict_with_error,
           inverse_of: :source_warehouse
  has_many :stock_transfers_in,    class_name: "StockTransfer",
           foreign_key: :destination_warehouse_id, dependent: :restrict_with_error,
           inverse_of: :destination_warehouse
  has_many :purchase_orders,       dependent: :restrict_with_error
  has_many :inventory_counts,      dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :code, presence: true, length: { maximum: 20 },
            uniqueness: { scope: :account_id, case_sensitive: false }
  validates :country_code, format: { with: /\A[A-Z]{2}\z/ }, allow_blank: true

  before_save :ensure_single_default

  scope :active,   -> { kept.where(active: true) }
  scope :default,  -> { where(is_default: true) }

  def default!
    transaction do
      account.warehouses.where.not(id: id).update_all(is_default: false)
      update!(is_default: true)
    end
  end

  private

  def ensure_single_default
    return unless is_default? && is_default_changed?
    account.warehouses.where.not(id: id).update_all(is_default: false)
  end
end
