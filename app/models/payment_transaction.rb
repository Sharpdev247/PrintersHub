class PaymentTransaction < ApplicationRecord
  TRANSACTION_TYPES = %w[charge authorize capture refund void].freeze
  GATEWAYS          = %w[stripe paypal jazzcash easypaisa bank_transfer manual].freeze

  belongs_to :payment

  enum :status, {
    pending:   0,
    success:   1,
    failed:    2,
    cancelled: 3
  }, prefix: true

  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }
  validates :gateway,          presence: true
  validates :amount,           numericality: { greater_than: 0 }
  validates :currency,         format: { with: /\A[A-Z]{3}\z/ }
  validates :status,           presence: true

  scope :successful,   -> { status_success }
  scope :failed,       -> { status_failed }
  scope :recent,       -> { order(created_at: :desc) }
  scope :for_gateway,  ->(g) { where(gateway: g) }
  scope :charges,      -> { where(transaction_type: "charge") }
  scope :refunds,      -> { where(transaction_type: "refund") }

  def total_refunded
    payment.payment_transactions.refunds.successful.sum(:amount)
  end
end
