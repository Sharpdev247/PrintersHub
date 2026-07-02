class Invoice < ApplicationRecord
  audited

  belongs_to :account                                    # seller account (issuer)
  belongs_to :buyer_account, class_name: "Account", optional: true
  belongs_to :order,                                     optional: true
  belongs_to :account_subscription, optional: true
  belongs_to :subscription_plan,    optional: true

  has_many :invoice_items, dependent: :destroy
  has_many :payments, ->(invoice) { where(account_id: invoice.account_id) },
           foreign_key: :account_id, primary_key: :account_id

  enum :status, {
    draft:          0,
    open:           1,
    paid:           2,
    void:           3,
    uncollectible:  4
  }, prefix: true

  validates :invoice_number, presence: true, uniqueness: true
  validates :currency,       format: { with: /\A[A-Z]{3}\z/ }
  validates :subtotal,       numericality: { greater_than_or_equal_to: 0 }
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount,     numericality: { greater_than_or_equal_to: 0 }
  validates :total,          numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_invoice_number, on: :create

  scope :paid,         -> { status_paid }
  scope :open,         -> { status_open }
  scope :recent,       -> { order(created_at: :desc) }
  scope :order_type,   -> { where(invoice_type: "order") }
  scope :for_account,  ->(acct) { where("account_id = ? OR buyer_account_id = ?", acct.id, acct.id) }

  def recalculate!
    self.subtotal = invoice_items.sum(&:amount)
    self.total    = subtotal - discount_amount + tax_amount
    save!
  end

  def mark_paid!(time = Time.current)
    update!(status: :paid, paid_at: time)
  end

  def void!
    update!(status: :void)
  end

  private

  def generate_invoice_number
    return if invoice_number.present?
    year = Time.current.year
    seq  = self.class.where("invoice_number LIKE ?", "INV-#{year}-%").count + 1
    self.invoice_number = "INV-#{year}-#{seq.to_s.rjust(5, '0')}"
  end
end
