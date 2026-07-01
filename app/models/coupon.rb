class Coupon < ApplicationRecord
  has_many :coupon_redemptions, dependent: :restrict_with_error
  has_many :redeemed_by_accounts, through: :coupon_redemptions, source: :account

  # Optional plan restriction FK added via migration
  belongs_to :subscription_plan, optional: true

  enum :discount_type, {
    percentage:       0,
    fixed_amount:     1,
    free_trial_days:  2
  }, prefix: true

  validates :code,           presence: true, uniqueness: { case_sensitive: false },
                             format: { with: /\A[A-Z0-9\-_]+\z/, message: "must be uppercase alphanumeric" }
  validates :name,           presence: true
  validates :discount_value, numericality: { greater_than: 0 }
  validates :max_redemptions, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :redemptions_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :percentage_within_range

  before_validation :upcase_code

  scope :active,   -> { where(active: true) }
  scope :valid_now, -> { active.where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def exhausted?
    max_redemptions.present? && redemptions_count >= max_redemptions
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def usable?
    active? && !exhausted? && !expired?
  end

  def redeemable_by?(account)
    usable? && !coupon_redemptions.exists?(account: account)
  end

  private

  def upcase_code
    self.code = code.to_s.upcase.strip
  end

  def percentage_within_range
    if discount_type_percentage? && discount_value.present?
      if discount_value <= 0 || discount_value > 100
        errors.add(:discount_value, "must be between 1 and 100 for percentage discounts")
      end
    end
  end
end
