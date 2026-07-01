class WarehouseZone < ApplicationRecord
  audited

  belongs_to :warehouse

  has_many :inventory_items, dependent: :nullify

  validates :name, presence: true, length: { maximum: 100 }
  validates :code, presence: true, length: { maximum: 20 },
            uniqueness: { scope: :warehouse_id, case_sensitive: false }
  validates :zone_type, inclusion: { in: %w[storage receiving dispatch quarantine returns] }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(zone_type: type) }
end
