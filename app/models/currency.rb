class Currency < ApplicationRecord
  validates :code,          presence: true, uniqueness: true,
                            format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" }
  validates :name,          presence: true
  validates :symbol,        presence: true
  validates :exchange_rate, numericality: { greater_than: 0 }

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:code) }
  scope :defaults, -> { where(is_default: true) }

  before_save :ensure_single_default, if: -> { is_default? && is_default_changed? }

  def self.default_currency
    find_by(is_default: true)
  end

  def self.for_code(code)
    active.find_by(code: code.to_s.upcase)
  end

  def convert_to(target_code, amount)
    target = self.class.for_code(target_code)
    return amount if target.nil? || target == self
    (amount / exchange_rate * target.exchange_rate).round(2)
  end

  def to_s = "#{code} — #{name} (#{symbol})"

  private

  def ensure_single_default
    self.class.where.not(id: id).update_all(is_default: false)
  end
end
