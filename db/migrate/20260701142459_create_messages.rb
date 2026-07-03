# Messages — individual messages within a conversation.
#
# FK strategies:
#   conversation → CASCADE  : deleting a conversation deletes all its messages
#   user         → RESTRICT : messages are historical record; cannot delete a user
#                             who has sent messages (admin must reassign or anonymise first)
#
# read_at — simple MVP read tracking for 2-person conversations.
#   The ConversationParticipant.last_read_message_id cursor is the scalable path
#   for multi-user threads. read_at remains useful for single-message receipt UX.
#
# edited_at, deleted_at — nullable scaffold columns for future features.
#   Zero migration cost now; unlocks edit/delete UI without schema change later.
#   deleted_at enables soft-delete: scope :visible -> { where(deleted_at: nil) }
#
# Resolves circular FK:
#   ConversationParticipant.last_read_message_id → messages.id
#   This FK can only be added after the messages table exists. It lives here.
class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,         null: false, foreign_key: { on_delete: :restrict }
      t.text :body,       null: false
      t.datetime :read_at             # MVP single-user read receipt
      t.datetime :edited_at           # future: message editing
      t.datetime :deleted_at          # future: soft-delete / moderation
      t.timestamps
    end

    # Primary query: load messages for a conversation in chronological order.
    add_index :messages, [ :conversation_id, :created_at ],
              name: "index_messages_on_conversation_and_created_at"

    # Find all unread messages in a conversation for the recipient.
    add_index :messages, [ :conversation_id, :read_at ],
              where: "read_at IS NULL",
              name: "index_messages_on_conversation_id_unread"

    # Resolve the deferred FK from conversation_participants.last_read_message_id.
    # NULLIFY: if a message is deleted, the read cursor resets gracefully.
    add_foreign_key :conversation_participants, :messages,
                    column: :last_read_message_id,
                    on_delete: :nullify
  end
end
