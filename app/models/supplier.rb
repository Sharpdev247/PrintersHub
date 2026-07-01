class Supplier < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account

  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :reorder_rules,   dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }
  validates :code, presence: true, length: { maximum: 30 },
            uniqueness: { scope: :account_id, case_sensitive: false }
  validates :currency, format: { with: /\A[A-Z]{3}\z/ }
  validates :lead_time_days, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :active, -> { kept.where(active: true) }

  def display_name
    "#{name} (#{code})"
  end
end
