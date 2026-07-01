# Conversations — a thread of messages optionally tied to a listing.
#
# Why listing_id is nullable (NULLIFY on delete):
#   A listing can be archived or deleted after a conversation has started.
#   The conversation history is valuable even without the listing context —
#   deleting it would confuse participants. NULLIFY preserves the thread.
#
# Why no buyer_id / seller_id columns:
#   Participants are stored in the conversation_participants join table.
#   This design supports: 2-person (buyer↔seller), admin joining, support
#   tickets, and future group conversations — without any schema change.
#
# updated_at serves as the "last activity" timestamp for inbox sorting.
class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :listing, null: true, foreign_key: { on_delete: :nullify }
      t.string :subject, limit: 255
      t.timestamps
    end

    # Inbox sort order: most recently active first.
    add_index :conversations, :updated_at, name: "index_conversations_on_updated_at"

    # Look up all conversations for a given listing (e.g. admin oversight).
    # (t.references auto-creates index on listing_id — this partial one covers
    #  non-null listings only, saving index space for nullified entries.)
    add_index :conversations, :listing_id, where: "listing_id IS NOT NULL",
              name: "index_conversations_on_listing_id_present"
  end
end
