class ProductVariant < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :product

  has_many :inventory_items,      dependent: :restrict_with_error
  has_many :purchase_order_items, dependent: :restrict_with_error

  validates :name,        presence: true, length: { maximum: 255 }
  validates :variant_sku, presence: true, length: { maximum: 100 },
            uniqueness: { scope: :product_id, case_sensitive: false }
  validates :cost_override,   numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :weight_override, numericality: { greater_than: 0 },             allow_nil: true
  validates :position,        numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { kept.where(active: true) }
  scope :ordered, -> { order(:position, :name) }

  def effective_cost
    cost_override || product.base_cost
  end

  def effective_weight
    weight_override || product.weight
  end

  def display_options
    options_data.map { |k, v| "#{k.humanize}: #{v}" }.join(", ")
  end

  def total_available
    inventory_items.sum("quantity_on_hand - reserved_quantity")
  end
end
