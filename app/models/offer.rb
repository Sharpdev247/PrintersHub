class Offer < ApplicationRecord
  # listing     → restrict (migration): cannot delete a listing with offers
  # buyer       → restrict (migration): preserve offer history
  # seller      → restrict (migration): preserve offer history
  # proposed_by → restrict (migration): preserve attribution
  # parent_offer → nullify (migration): chain links clear gracefully on deletion
  belongs_to :listing
  belongs_to :buyer,       class_name: "User", foreign_key: :buyer_id
  belongs_to :seller,      class_name: "User", foreign_key: :seller_id
  belongs_to :proposed_by, class_name: "User", foreign_key: :proposed_by_id
  belongs_to :parent_offer, class_name: "Offer", optional: true

  has_many :counter_offers, class_name: "Offer", foreign_key: :parent_offer_id,
           dependent: :nullify

  enum :status, {
    pending:   0,
    accepted:  1,
    rejected:  2,
    countered: 3,
    withdrawn: 4,
    expired:   5
  }, prefix: true

  validates :amount,   presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true,
                       format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" }
  validates :status,   presence: true
  validate  :buyer_is_not_seller
  validate  :listing_must_be_published, on: :create
  validate  :proposed_by_is_participant

  before_create :set_seller_from_listing

  scope :pending,   -> { where(status: statuses[:pending]) }
  scope :active,    -> { where(status: [statuses[:pending], statuses[:countered]]) }
  scope :for_buyer, ->(user) { where(buyer: user) }
  scope :for_seller, ->(user) { where(seller: user) }
  scope :root,      -> { where(parent_offer_id: nil) }

  def accept!
    update!(status: :accepted)
  end

  def reject!
    update!(status: :rejected)
  end

  def withdraw!
    update!(status: :withdrawn)
  end

  # Creates a counter-offer and marks this offer as countered.
  # The proposer flips: if buyer made the original, seller makes the counter.
  def counter!(amount:, proposed_by:, message: nil, expires_at: nil)
    raise ArgumentError, "amount must be positive" unless amount.positive?
    raise ArgumentError, "proposed_by must be buyer or seller" unless
      [buyer_id, seller_id].include?(proposed_by.id)

    counter = nil
    transaction do
      counter = self.class.create!(
        listing:       listing,
        buyer:         buyer,
        seller:        seller,
        proposed_by:   proposed_by,
        parent_offer:  self,
        amount:        amount,
        currency:      currency,
        message:       message,
        expires_at:    expires_at
      )
      update!(status: :countered)
    end
    counter
  end

  def negotiation_chain
    chain = [self]
    chain.unshift(chain.first.parent_offer) while chain.first.parent_offer_id.present?
    chain
  end

  private

  def set_seller_from_listing
    self.seller_id ||= listing&.user_id
  end

  def buyer_is_not_seller
    return unless buyer_id.present? && seller_id.present?
    errors.add(:buyer, "cannot make an offer on their own listing") if buyer_id == seller_id
  end

  def listing_must_be_published
    errors.add(:listing, "must be published to receive offers") unless listing&.status_published?
  end

  def proposed_by_is_participant
    return unless proposed_by_id.present?
    unless [buyer_id, seller_id].include?(proposed_by_id)
      errors.add(:proposed_by, "must be either the buyer or seller")
    end
  end
end
