class Account < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  include Discard::Model
  audited

  # Memberships: users join accounts via the Membership join model
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # Company profiles belonging to this account (business identity)
  has_many :companies, dependent: :restrict_with_error

  # Marketplace assets
  has_many :listings, dependent: :restrict_with_error

  # Inventory & warehouse
  has_many :warehouses,         dependent: :restrict_with_error
  has_many :suppliers,          dependent: :restrict_with_error
  has_many :products,           dependent: :restrict_with_error
  has_many :purchase_orders,    dependent: :restrict_with_error
  has_many :inventory_counts,   dependent: :restrict_with_error
  has_many :stock_transfers,    dependent: :restrict_with_error
  has_many :stock_adjustments,  dependent: :restrict_with_error
  has_many :inventory_transactions, dependent: :restrict_with_error
  has_many :carts,           dependent: :destroy
  has_many :orders_as_buyer,  class_name: "Order", foreign_key: :buyer_account_id,
           dependent: :restrict_with_error, inverse_of: :buyer_account
  has_many :orders_as_seller, class_name: "Order", foreign_key: :seller_account_id,
           dependent: :restrict_with_error, inverse_of: :seller_account
  has_many :shipments,       dependent: :restrict_with_error

  # Subscription & billing
  has_many :account_subscriptions, dependent: :restrict_with_error
  has_one  :active_subscription, -> { kept.where(status: [ 0, 1, 2 ]).order(created_at: :desc) },
           class_name: "AccountSubscription"
  has_many :invoices, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error
  has_many :coupon_redemptions, dependent: :restrict_with_error
  has_many :subscription_usages, dependent: :destroy
  has_many :api_tokens,          dependent: :destroy

  enum :account_type, {
    individual:  0,
    company:     1,
    dealer:      2,
    vendor:      3,
    enterprise:  4
  }, prefix: true

  enum :status, {
    active:    0,
    suspended: 1,
    closed:    2
  }, prefix: true

  validates :name,  presence: true, length: { minimum: 2, maximum: 150 }
  validates :slug,  presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: /\Ahttps?:\/\/.+\z/ }, allow_blank: true
  validates :phone, format: { with: /\A[\d\s\+\-\(\)\.]{7,20}\z/ }, allow_blank: true

  scope :active,    -> { kept.status_active }
  scope :verified,  -> { where(verified: true) }
  scope :ordered,   -> { order(:name) }

  def verify!(time = Time.current)
    update!(verified: true, verified_at: time)
  end

  def owner
    memberships.kept.find_by(role: Membership.roles[:owner])&.user
  end

  def member?(user)
    memberships.kept.exists?(user: user)
  end

  def member_role(user)
    memberships.kept.find_by(user: user)&.role
  end

  # Returns the current active subscription's plan, or nil for free accounts.
  def current_plan
    active_subscription&.subscription_plan
  end

  # Looks up a feature limit/value for this account's current plan.
  # Returns nil if no subscription or feature not found.
  def plan_feature(feature_key)
    current_plan&.feature(feature_key)
  end

  def within_limit?(feature_key, current_count)
    feature = plan_feature(feature_key)
    return true if feature.nil?
    feature.unlimited? || current_count < feature.numeric_value
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
