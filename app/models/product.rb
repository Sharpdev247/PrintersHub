class Product < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account
  belongs_to :brand,         optional: true
  belongs_to :category,      optional: true
  belongs_to :printer_model, optional: true

  has_many :product_variants,  dependent: :destroy
  has_many :inventory_items,   through: :product_variants
  has_many :listings,          dependent: :nullify

  enum :status, {
    draft:       0,
    active:      1,
    discontinued: 2,
    archived:    3
  }, prefix: true

  validates :name,         presence: true, length: { maximum: 255 }
  validates :sku,          presence: true, length: { maximum: 100 },
            uniqueness: { scope: :account_id, case_sensitive: false }
  validates :base_cost,    numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :weight,       numericality: { greater_than: 0 },             allow_nil: true
  validates :cost_currency, format: { with: /\A[A-Z]{3}\z/ }
  validates :weight_unit,   inclusion: { in: %w[kg lb oz g] }
  validates :dimension_unit, inclusion: { in: %w[cm in mm] }
  validates :barcode_type,  inclusion: { in: %w[EAN13 EAN8 UPC ISBN QR CODE128 CODE39] }

  scope :active, -> { kept.status_active }
  scope :with_variants, -> { where(has_variants: true) }
  scope :tracking_inventory, -> { where(track_inventory: true) }

  def available_quantity
    inventory_items.sum("quantity_on_hand - reserved_quantity")
  end

  def total_on_hand
    inventory_items.sum(:quantity_on_hand)
  end
end
