class TaxRate < ApplicationRecord
  enum :tax_type, {
    sales_tax: 0,
    vat:       1,
    gst:       2,
    pst:       3,
    custom:    4
  }, prefix: true

  validates :name,         presence: true
  validates :country_code, presence: true,
                           format: { with: /\A[A-Z]{2}\z/, message: "must be a 2-letter ISO 3166-1 alpha-2 code" }
  validates :rate,         presence: true,
                           numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :tax_type,     presence: true

  scope :active,            -> { where(active: true) }
  scope :for_country,       ->(code) { where(country_code: code.to_s.upcase) }

  def rate_percentage
    (rate * 100).round(4)
  end

  def display_name
    "#{name} (#{rate_percentage}%)"
  end

  def self.applicable_for(country_code:, state_code: nil)
    scope = active.where(country_code: country_code.to_s.upcase)
    if state_code.present?
      scope.where(state_code: [state_code.to_s.upcase, nil])
           .order(Arel.sql("CASE WHEN state_code IS NOT NULL THEN 0 ELSE 1 END"))
    else
      scope.where(state_code: nil)
    end
  end
end
