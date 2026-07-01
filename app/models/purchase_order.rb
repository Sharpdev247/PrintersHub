class PurchaseOrder < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account
  belongs_to :supplier
  belongs_to :warehouse
  belongs_to :created_by,  class_name: "User", foreign_key: :created_by_id,  optional: true
  belongs_to :approved_by, class_name: "User", foreign_key: :approved_by_id, optional: true

  has_many :purchase_order_items, dependent: :destroy

  enum :status, {
    draft:      0,
    submitted:  1,
    confirmed:  2,
    shipped:    3,
    partial:    4,
    received:   5,
    cancelled:  6
  }, prefix: true

  before_validation :generate_po_number, on: :create

  validates :po_number,    presence: true, uniqueness: true
  validates :subtotal,     numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :currency,     format: { with: /\A[A-Z]{3}\z/ }

  scope :recent,   -> { kept.order(created_at: :desc) }
  scope :open,     -> { kept.where(status: [:draft, :submitted, :confirmed, :shipped, :partial]) }

  def recalculate!
    sub = purchase_order_items.sum(:total_cost)
    update!(subtotal: sub, total_amount: sub + tax_amount + shipping_cost)
  end

  def submit!
    update!(status: :submitted, submitted_at: Time.current)
  end

  def approve!(user)
    update!(status: :confirmed, approved_by: user, approved_at: Time.current)
  end

  def receive_items!(items_received, performed_by: nil)
    transaction do
      items_received.each do |poi_id, qty|
        poi = purchase_order_items.find(poi_id)
        poi.receive!(qty, performed_by: performed_by)
      end
      recalculate!
      all_received = purchase_order_items.all? { |i| i.quantity_received >= i.quantity_ordered }
      update!(status: all_received ? :received : :partial,
              received_at: all_received ? Time.current : nil)
    end
  end

  private

  def generate_po_number
    return if po_number.present?
    year = Time.current.year
    seq  = PurchaseOrder.where("po_number LIKE ?", "PO-#{year}-%").count + 1
    self.po_number = "PO-#{year}-#{seq.to_s.rjust(5, '0')}"
  end
end
