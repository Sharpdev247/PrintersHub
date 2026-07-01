class CouponRedemption < ApplicationRecord
  belongs_to :coupon
  belongs_to :account

  has_one :account_subscription

  validates :coupon_id, uniqueness: { scope: :account_id,
                                      message: "has already been redeemed by this account" }
  validates :discount_applied, numericality: { greater_than: 0 }

  after_create :increment_coupon_count

  private

  def increment_coupon_count
    coupon.increment!(:redemptions_count)
  end
end
