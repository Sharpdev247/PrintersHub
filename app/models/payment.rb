class Payment < ApplicationRecord
  audited

  belongs_to :account
  belongs_to :invoice, optional: true

  enum :status, {
    pending:   0,
    completed: 1,
    failed:    2,
    refunded:  3
  }, prefix: true

  validates :amount,   numericality: { greater_than: 0 }
  validates :currency, format: { with: /\A[A-Z]{3}\z/ }
  validate  :invoice_belongs_to_same_account

  scope :completed, -> { status_completed }
  scope :recent,    -> { order(created_at: :desc) }
  scope :for_provider, ->(p) { where(payment_provider: p) }

  def mark_completed!(time = Time.current)
    update!(status: :completed, paid_at: time)
  end

  def mark_failed!(reason: nil)
    update!(status: :failed, failure_reason: reason)
  end

  private

  def invoice_belongs_to_same_account
    return unless invoice_id.present?
    unless invoice&.account_id == account_id
      errors.add(:invoice, "must belong to the same account")
    end
  end
end
