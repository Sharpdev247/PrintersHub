# ConversationParticipants — join table linking users to conversations.
#
# Why this table instead of buyer_id/seller_id on conversations:
#   Every extra participant (admin, support agent, group member) added in the
#   future would require adding a new nullable FK column to conversations.
#   A join table scales to N participants with zero schema changes.
#
# last_read_message_id — O(1) unread count cursor.
#   Instead of scanning messages WHERE read_at IS NULL per user, store the id
#   of the last message each participant has read. Unread count becomes:
#     messages.where("id > ?", last_read_message_id).count
#   The FK for this column is deferred until create_messages (circular dependency).
#
# role enum: 0=participant, 1=initiator, 2=moderator
#   Initiator identifies who started the conversation (the buyer).
#   Moderator is reserved for admin / support agents.
#
# FK strategies:
#   conversation → CASCADE : removing a conversation removes all its participants
#   user         → CASCADE : removing a user removes their participation records
class CreateConversationParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,         null: false, foreign_key: { on_delete: :cascade }
      t.integer    :role,         null: false, default: 0
      t.bigint     :last_read_message_id  # FK added in create_messages (circular dep)
      t.datetime   :joined_at,   null: false
      t.datetime   :left_at                # soft-leave: nil = still in conversation
      t.timestamps
    end

    # A user can only appear once per conversation.
    add_index :conversation_participants, [:conversation_id, :user_id], unique: true,
              name: "index_conv_participants_on_conv_and_user"

    # Inbox query: "all conversations this user is in, newest first".
    add_index :conversation_participants, :user_id,
              name: "index_conv_participants_on_user_id"

    # Partial index: only index the non-null last_read_message_id rows.
    add_index :conversation_participants, :last_read_message_id,
              where: "last_read_message_id IS NOT NULL",
              name: "index_conv_participants_on_last_read_message"
  end
end
