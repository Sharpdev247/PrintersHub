class Order < ApplicationRecord
  belongs_to :buyer_account,    class_name: "Account", inverse_of: :orders_as_buyer
  belongs_to :seller_account,   class_name: "Account", inverse_of: :orders_as_seller
  belongs_to :created_by,       class_name: "User"
  belongs_to :billing_address,  class_name: "Address", optional: true
  belongs_to :shipping_address, class_name: "Address", optional: true
  belongs_to :cancelled_by,     class_name: "User",    optional: true

  has_many :order_items,           dependent: :destroy
  has_many :order_status_histories, dependent: :destroy
  has_many :shipments,             dependent: :restrict_with_error
  has_many :payments,              -> { where(payment_context: Payment.payment_contexts[:order]) },
           class_name: "Payment",  primary_key: :id, foreign_key: :order_id,
           dependent: :nullify, inverse_of: :order

  enum :status, {
    draft:             0,
    pending_payment:   1,
    payment_confirmed: 2,
    processing:        3,
    partially_shipped: 4,
    shipped:           5,
    delivered:         6,
    completed:         7,
    cancelled:         8,
    refunded:          9,
    disputed:          10
  }, prefix: true

  before_validation :generate_order_number, on: :create

  validates :order_number,    presence: true, uniqueness: true
  validates :currency,        format: { with: /\A[A-Z]{3}\z/ }
  validates :subtotal,        numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount,      numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :total,           numericality: { greater_than_or_equal_to: 0 }
  validate  :buyer_and_seller_are_different

  scope :for_buyer,  ->(account) { where(buyer_account: account) }
  scope :for_seller, ->(account) { where(seller_account: account) }
  scope :recent,     -> { order(created_at: :desc) }
  scope :paid,       -> { where.not(paid_at: nil) }
  scope :active,     -> { where(status: [statuses[:pending_payment], statuses[:payment_confirmed],
                                          statuses[:processing], statuses[:partially_shipped],
                                          statuses[:shipped]]) }

  def recalculate!
    items = order_items.reload
    new_subtotal  = items.sum { |i| i.unit_price * i.quantity }
    new_tax       = items.sum(&:tax_amount)
    new_discount  = items.sum(&:discount_amount)
    new_total     = [new_subtotal + new_tax + shipping_amount - new_discount, 0].max
    update!(subtotal: new_subtotal, tax_amount: new_tax, discount_amount: new_discount, total: new_total)
  end

  def transition_to!(new_status, changed_by: nil, note: nil, source: "system")
    old_status = status
    ts_col     = "#{new_status}_at"
    attrs      = { status: new_status }
    attrs[ts_col] = Time.current if self.class.column_names.include?(ts_col.to_s)

    transaction do
      update!(attrs)
      order_status_histories.create!(
        from_status: self.class.statuses[old_status],
        to_status:   self.class.statuses[new_status.to_s],
        changed_by:  changed_by,
        note:        note,
        source:      source
      )
    end
  end

  def cancel!(cancelled_by:, reason: nil)
    transaction do
      update!(cancelled_by: cancelled_by, cancellation_reason: reason)
      transition_to!(:cancelled, changed_by: cancelled_by, note: reason, source: "user")
    end
  end

  def cancellable?
    status_draft? || status_pending_payment? || status_payment_confirmed? || status_processing?
  end

  def display_status
    status.humanize
  end

  def capturable_payment
    payments.where(status: Payment.statuses[:pending]).order(created_at: :desc).first
  end

  private

  def generate_order_number
    return if order_number.present?
    year     = Time.current.strftime("%Y")
    sequence = self.class.where("order_number LIKE ?", "ORD-#{year}-%").count + 1
    self.order_number = "ORD-#{year}-#{sequence.to_s.rjust(6, '0')}"
  end

  def buyer_and_seller_are_different
    return unless buyer_account_id.present? && seller_account_id.present?
    if buyer_account_id == seller_account_id
      errors.add(:buyer_account, "cannot be the same as the seller account")
    end
  end
end
