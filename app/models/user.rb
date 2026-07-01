class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :trackable

  # Profile is the extended identity — destroyed when user is destroyed (mirrors DB cascade)
  has_one :profile, dependent: :destroy

  # Many-to-many roles — a user can be buyer, seller, dealer, vendor, service_provider simultaneously
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  # A user can own multiple business entities
  has_many :companies, dependent: :restrict_with_error
  has_many :listings, dependent: :restrict_with_error

  # Personal addresses (home, billing, etc.) separate from company addresses
  has_many :addresses, as: :addressable, dependent: :destroy

  # ── Interaction layer ────────────────────────────────────────────────────────
  has_many :favorites, dependent: :destroy
  has_many :favorited_listings, through: :favorites, source: :listing

  has_many :saved_searches, dependent: :destroy

  # Conversation membership via join table — user appears in many conversations
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants

  has_many :sent_messages, class_name: "Message", dependent: :restrict_with_error

  # Offers where this user is the buyer (made the offer)
  has_many :offers_made, class_name: "Offer", foreign_key: :buyer_id, dependent: :restrict_with_error
  # Offers where this user is the seller (received the offer)
  has_many :offers_received, class_name: "Offer", foreign_key: :seller_id, dependent: :restrict_with_error

  # Reviews written and received
  has_many :reviews_given,    class_name: "Review", foreign_key: :reviewer_id, dependent: :restrict_with_error
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, dependent: :restrict_with_error

  has_many :notifications, dependent: :destroy

  # Convenience predicates — avoids `user.roles.map(&:name).include?("buyer")` callsites
  def role?(role_name)
    roles.exists?(name: role_name.to_s.downcase)
  end
end
