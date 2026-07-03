# Notifications — in-app notification feed per user.
#
# Why JSONB for data:
#   The data payload carries event-specific context (offer amount, listing title,
#   sender name, deep-link URL). Adding a new notification type like
#   "listing_price_dropped" just adds a new key to the JSONB payload —
#   no schema migration needed. The GIN index makes the payload queryable
#   for future analytics ("how many offer_received notifications were sent today?").
#
# Why polymorphic notifiable columns:
#   notifiable_type / notifiable_id allow `notification.notifiable` to return the
#   associated Offer, Message, Listing, or Review object directly. Without this,
#   the frontend must decode the data JSONB to build deep links. With it:
#     notification.notifiable  # => #<Offer id=42 ...>
#   Both columns are nullable (not all notification types link to a resource).
#
# FK strategy:
#   user → CASCADE : delete all notifications when a user is deleted
#
# notification_type is a string rather than an integer enum so that new event
# types can be added in application config without a DB migration or enum
# value reordering risk.
class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user,              null: false, foreign_key: { on_delete: :cascade }
      t.string  :title,                null: false
      t.text    :body
      t.string  :notification_type,    null: false
      t.jsonb   :data,                 null: false, default: {}
      t.datetime :read_at
      # Polymorphic link to the source resource (Offer, Message, Listing, Review, etc.)
      t.string  :notifiable_type
      t.bigint  :notifiable_id
      t.timestamps
    end

    # Primary inbox query: user's notifications, newest first, paginated.
    add_index :notifications, [ :user_id, :created_at ],
              name: "index_notifications_on_user_and_created_at"

    # Unread count badge: WHERE user_id = ? AND read_at IS NULL.
    add_index :notifications, [ :user_id, :read_at ],
              where: "read_at IS NULL",
              name: "index_notifications_on_user_id_unread"

    # Deep-link reverse lookup: find all notifications for a given resource.
    add_index :notifications, [ :notifiable_type, :notifiable_id ],
              where: "notifiable_type IS NOT NULL",
              name: "index_notifications_on_notifiable"

    # JSONB payload search for future analytics/admin queries.
    add_index :notifications, :data, using: :gin,
              name: "index_notifications_on_data_gin"
  end
end
