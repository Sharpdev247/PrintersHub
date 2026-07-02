class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :trackable,
         :timeoutable

  # ── Account membership (tenant access) ─────────────────────────────────────
  # A user can belong to multiple accounts via Membership (role lives on join).
  has_many :memberships, dependent: :destroy
  has_many :accounts, through: :memberships

  # ── Identity ────────────────────────────────────────────────────────────────
  has_one  :profile,    dependent: :destroy
  has_many :addresses,  as: :addressable, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # ── Marketplace ─────────────────────────────────────────────────────────────
  has_many :listings,   dependent: :restrict_with_error
  has_many :favorites,  dependent: :destroy
  has_many :favorited_listings, through: :favorites, source: :listing
  has_many :saved_searches, dependent: :destroy
  has_many :reviews_given,    class_name: "Review",
                              foreign_key: :reviewer_id,
                              dependent: :restrict_with_error,
                              inverse_of: :reviewer
  has_many :reviews_received, class_name: "Review",
                              foreign_key: :reviewee_id,
                              dependent: :restrict_with_error,
                              inverse_of: :reviewee

  # ── Commerce ────────────────────────────────────────────────────────────────
  has_many :orders_created,   class_name: "Order",
                              foreign_key: :created_by_id,
                              dependent: :restrict_with_error,
                              inverse_of: :created_by

  # ── API tokens ──────────────────────────────────────────────────────────────
  has_many :api_tokens, dependent: :destroy

  # ── Messaging ───────────────────────────────────────────────────────────────
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: "Message",
                           foreign_key: :sender_id,
                           dependent: :restrict_with_error,
                           inverse_of: :sender

  # ── Convenience helpers ─────────────────────────────────────────────────────

  # Primary account — the first active membership (owner seat takes precedence).
  def primary_account
    accounts.merge(Membership.kept.order(created_at: :asc)).first
  end

  # Role within a specific account.
  def role_for(account)
    memberships.kept.find_by(account: account)&.role
  end

  # True if the user holds the given role in the given account.
  def role?(role_name, account:)
    memberships.kept.exists?(account: account, role: Membership.roles[role_name.to_sym])
  end

  # True if the user is an owner of any account.
  def account_owner?
    memberships.kept.role_owner.exists?
  end

  def full_name
    profile ? "#{profile.first_name} #{profile.last_name}".strip : email
  end
end
