class Shipment < ApplicationRecord
  WEIGHT_UNITS = %w[kg lb oz g].freeze

  belongs_to :order
  belongs_to :account
  has_many   :shipment_items, dependent: :destroy
  has_many   :order_items,    through: :shipment_items

  enum :status, {
    pending:            0,
    preparing:          1,
    picked_up:          2,
    in_transit:         3,
    out_for_delivery:   4,
    delivered:          5,
    attempted_delivery: 6,
    exception:          7,
    returned:           8
  }, prefix: true

  validates :weight_unit,   inclusion: { in: WEIGHT_UNITS }, allow_nil: true
  validates :weight,        numericality: { greater_than: 0 }, allow_nil: true
  validates :shipping_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :tracking_number_length

  scope :active,    -> { where.not(status: [statuses[:delivered], statuses[:returned]]) }
  scope :delivered, -> { status_delivered }
  scope :for_order, ->(o) { where(order: o) }

  def mark_shipped!(tracking_number: nil, carrier: nil)
    attrs = { status: :picked_up, shipped_at: Time.current }
    attrs[:tracking_number] = tracking_number if tracking_number.present?
    attrs[:carrier]         = carrier         if carrier.present?
    update!(attrs)
    order.transition_to!(:shipped, source: "system", note: "Shipment #{id} picked up")
  end

  def mark_delivered!
    update!(status: :delivered, delivered_at: Time.current)
    if order.shipments.all?(&:status_delivered?)
      order.transition_to!(:delivered, source: "system", note: "All shipments delivered")
    end
  end

  def in_transit?
    status_in_transit? || status_out_for_delivery? || status_picked_up?
  end

  private

  def tracking_number_length
    return if tracking_number.blank?
    unless tracking_number.length.between?(5, 100)
      errors.add(:tracking_number, "must be between 5 and 100 characters")
    end
  end
end
