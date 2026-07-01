class InventoryItem < ApplicationRecord
  audited

  belongs_to :product_variant
  belongs_to :warehouse
  belongs_to :warehouse_zone, optional: true

  has_many :inventory_transactions, dependent: :restrict_with_error
  has_many :stock_reservations,     dependent: :restrict_with_error
  has_many :stock_adjustments,      dependent: :restrict_with_error
  has_many :stock_transfer_items,   dependent: :restrict_with_error
  has_many :purchase_order_items,   dependent: :nullify
  has_many :inventory_count_items,  dependent: :restrict_with_error
  has_one  :reorder_rule,           dependent: :destroy
  has_many :listings,               dependent: :nullify

  delegate :product, to: :product_variant
  delegate :account, to: :warehouse

  validates :quantity_on_hand,   numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity,  numericality: { greater_than_or_equal_to: 0 }
  validates :unit_cost,          numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cost_currency,      format: { with: /\A[A-Z]{3}\z/ }

  validate :reserved_does_not_exceed_on_hand, unless: :allow_backorders?
  validate :zone_belongs_to_warehouse

  scope :active,        -> { where(active: true) }
  scope :low_stock,     -> { where("quantity_on_hand - reserved_quantity <= reorder_point") }
  scope :out_of_stock,  -> { where("quantity_on_hand - reserved_quantity <= 0") }
  scope :for_warehouse, ->(wh) { where(warehouse_id: wh) }

  def available_quantity
    quantity_on_hand - reserved_quantity
  end

  def reserve!(quantity:, order_item:, performed_by: nil)
    transaction do
      raise InsufficientStockError, "Only #{available_quantity} units available" \
        if available_quantity < quantity && !allow_backorders?

      reservation = stock_reservations.create!(
        order_item: order_item,
        quantity:   quantity,
        status:     :pending
      )
      record_transaction!(
        type:         :reservation,
        direction:    :neutral,
        quantity:     -quantity,
        reference:    order_item,
        performed_by: performed_by,
        source:       "system"
      )
      increment!(:reserved_quantity, quantity)
      reservation
    end
  end

  def release_reservation!(reservation, performed_by: nil)
    transaction do
      reservation.update!(status: :released, released_at: Time.current)
      record_transaction!(
        type:         :release,
        direction:    :neutral,
        quantity:     reservation.quantity,
        reference:    reservation.order_item,
        performed_by: performed_by,
        source:       "system"
      )
      decrement!(:reserved_quantity, reservation.quantity)
    end
  end

  def receive!(quantity:, purchase_order_item: nil, unit_cost: nil, lot_number: nil, performed_by: nil)
    transaction do
      record_transaction!(
        type:                 :purchase,
        direction:            :in,
        quantity:             quantity,
        reference:            purchase_order_item,
        lot_number:           lot_number,
        unit_cost_override:   unit_cost,
        performed_by:         performed_by,
        source:               "user"
      )
      increment!(:quantity_on_hand, quantity)
      update!(unit_cost: unit_cost) if unit_cost.present?
    end
  end

  def adjust!(quantity_change:, reason_code:, notes: nil, performed_by: nil)
    transaction do
      adj = stock_adjustments.create!(
        account:         warehouse.account,
        adjusted_by_id:  performed_by,
        quantity_change: quantity_change,
        reason_code:     reason_code,
        notes:           notes,
        adjusted_at:     Time.current
      )
      record_transaction!(
        type:         :adjustment,
        direction:    quantity_change > 0 ? :in : :out,
        quantity:     quantity_change,
        reference:    adj,
        performed_by: performed_by,
        source:       "user"
      )
      increment!(:quantity_on_hand, quantity_change)
    end
  end

  class InsufficientStockError < StandardError; end

  private

  def reserved_does_not_exceed_on_hand
    if reserved_quantity > quantity_on_hand
      errors.add(:reserved_quantity, "cannot exceed quantity on hand")
    end
  end

  def zone_belongs_to_warehouse
    return unless warehouse_zone_id.present?
    unless warehouse_zone&.warehouse_id == warehouse_id
      errors.add(:warehouse_zone, "must belong to the same warehouse")
    end
  end

  def record_transaction!(type:, direction:, quantity:, reference: nil, performed_by: nil,
                           source: "system", lot_number: nil, unit_cost_override: nil)
    inventory_transactions.create!(
      account:          warehouse.account,
      transaction_type: type,
      direction:        direction,
      quantity_change:  quantity,
      quantity_before:  quantity_on_hand,
      quantity_after:   quantity_on_hand + quantity,
      unit_cost:        unit_cost_override || unit_cost,
      reference_type:   reference&.class&.name,
      reference_id:     reference&.id,
      lot_number:       lot_number,
      performed_by_id:  performed_by,
      performed_at:     Time.current,
      source:           source
    )
  end
end
