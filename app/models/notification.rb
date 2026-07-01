class Notification < ApplicationRecord
  TYPES = %w[
    offer_received
    offer_accepted
    offer_rejected
    offer_countered
    offer_withdrawn
    offer_expired
    new_message
    listing_approved
    listing_rejected
    listing_published
    review_received
    system
  ].freeze

  # user → cascade (migration): user deletion removes all their notifications
  belongs_to :user

  # Optional polymorphic link to the source resource.
  # notification.notifiable  # => #<Offer ...> / #<Message ...> / #<Listing ...>
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :title,             presence: true, length: { maximum: 200 }
  validates :notification_type, presence: true, inclusion: { in: TYPES }

  scope :unread,    -> { where(read_at: nil) }
  scope :read,      -> { where.not(read_at: nil) }
  scope :recent,    -> { order(created_at: :desc) }
  scope :for_type,  ->(type) { where(notification_type: type) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  # Convenience factory — use this rather than calling .create! directly.
  #
  # Example:
  #   Notification.deliver(
  #     user:     listing.user,
  #     type:     "offer_received",
  #     title:    "New offer on #{listing.title}",
  #     body:     "#{buyer.profile.full_name} offered #{offer.amount}",
  #     data:     { offer_id: offer.id, amount: offer.amount, currency: offer.currency },
  #     notifiable: offer
  #   )
  def self.deliver(user:, type:, title:, body: nil, data: {}, notifiable: nil)
    create!(
      user:              user,
      notification_type: type,
      title:             title,
      body:              body,
      data:              data,
      notifiable:        notifiable
    )
  end

  def self.mark_all_read_for(user)
    where(user: user, read_at: nil).update_all(read_at: Time.current)
  end
end
