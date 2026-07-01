class Conversation < ApplicationRecord
  # listing → nullify (migration): listing deletion clears listing_id but keeps the thread
  belongs_to :listing, optional: true

  # Participants via join table — N-user capable, no buyer_id/seller_id columns needed.
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user

  has_many :messages, dependent: :destroy

  scope :recent,       -> { order(updated_at: :desc) }
  scope :for_listing,  ->(listing) { where(listing: listing) }

  # Start a conversation between two users about a listing.
  # Idempotent: returns existing conversation if one already exists between
  # these two participants on this listing.
  def self.between(initiator:, recipient:, listing: nil, subject: nil)
    existing = joins(:conversation_participants)
                 .where(listing: listing)
                 .where(conversation_participants: { user_id: initiator.id })
                 .select { |c| c.participant?(recipient) }
                 .first
    return existing if existing

    transaction do
      conv = create!(listing: listing, subject: subject)
      conv.conversation_participants.create!(user: initiator,  role: :initiator,   joined_at: Time.current)
      conv.conversation_participants.create!(user: recipient,  role: :participant, joined_at: Time.current)
      conv
    end
  end

  def participant?(user)
    conversation_participants.exists?(user: user)
  end

  # Returns the other participant in a 2-person conversation.
  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end

  def unread_count_for(user)
    cp = conversation_participants.find_by(user: user)
    return 0 unless cp
    if cp.last_read_message_id.present?
      messages.where("id > ?", cp.last_read_message_id).count
    else
      messages.count
    end
  end
end
