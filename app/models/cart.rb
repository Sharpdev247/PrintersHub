class Cart < ApplicationRecord
  include Discard::Model

  belongs_to :account
  belongs_to :created_by, class_name: "User"
  has_many   :cart_items, dependent: :destroy
  has_many   :listings,   through: :cart_items

  enum :status, {
    active:       0,
    abandoned:    1,
    checked_out:  2,
    merged:       3
  }, prefix: true

  validates :currency, presence: true,
                       format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" }
  validate  :one_active_cart_per_account, on: :create

  scope :active,     -> { kept.status_active }
  scope :abandoned,  -> { kept.status_abandoned }

  def subtotal
    cart_items.sum { |ci| ci.unit_price * ci.quantity }
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def empty?
    cart_items.none?
  end

  def add_listing!(listing, quantity: 1, added_by: nil)
    raise ArgumentError, "quantity must be positive" unless quantity.positive?

    item = cart_items.find_or_initialize_by(listing: listing)
    if item.new_record?
      item.unit_price = listing.price
      item.currency   = listing.currency
      item.quantity   = quantity
    else
      item.quantity  += quantity
    end
    item.added_by = added_by
    item.save!
    item
  end

  def remove_listing!(listing)
    cart_items.find_by(listing: listing)&.destroy
  end

  def checkout!
    update!(status: :checked_out)
  end

  def abandon!
    update!(status: :abandoned)
  end

  def self.active_for(account)
    active.find_by(account: account)
  end

  def self.find_or_create_for(account:, created_by:, currency: "USD")
    active.find_by(account: account) ||
      create!(account: account, created_by: created_by, currency: currency)
  end

  private

  def one_active_cart_per_account
    return unless status_active?
    if self.class.active.where(account: account).exists?
      errors.add(:account, "already has an active cart")
    end
  end
end
