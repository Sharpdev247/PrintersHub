class ConversationParticipant < ApplicationRecord
  # conversation → cascade (migration)
  # user         → cascade (migration)
  belongs_to :conversation
  belongs_to :user

  # last_read_message_id → nullify (migration): cursor resets if message deleted
  belongs_to :last_read_message, class_name: "Message", optional: true

  # 0=participant (default), 1=initiator (started the conversation), 2=moderator
  enum :role, { participant: 0, initiator: 1, moderator: 2 }, prefix: true

  validates :user_id, uniqueness: { scope: :conversation_id,
                                    message: "is already a participant in this conversation" }
  validates :joined_at, presence: true

  before_validation :set_joined_at, on: :create

  # Mark all messages in the conversation as read for this participant by
  # advancing the cursor to the latest message.
  def mark_as_read!
    last_msg = conversation.messages.order(:created_at).last
    update!(last_read_message_id: last_msg&.id) if last_msg
  end

  def unread_messages
    if last_read_message_id.present?
      conversation.messages.where("id > ?", last_read_message_id)
    else
      conversation.messages
    end
  end

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end
end
