class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true
  validates :quantity,    numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price,  numericality: { greater_than_or_equal_to: 0 }
  validates :amount,      numericality: { greater_than_or_equal_to: 0 }
  validates :currency,    format: { with: /\A[A-Z]{3}\z/ }

  before_validation :calculate_amount

  private

  def calculate_amount
    self.amount = (unit_price || 0) * (quantity || 1)
  end
end
