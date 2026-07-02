class ContactNote < ApplicationRecord
  belongs_to :contact
  belongs_to :author, class_name: "User"

  validates :body,      presence: true
  validates :note_type, inclusion: { in: Contact::NOTE_TYPES }

  scope :recent,       -> { order(created_at: :desc) }
  scope :follow_ups,   -> { where(note_type: "follow_up").where.not(follow_up_at: nil) }
  scope :upcoming,     -> { follow_ups.where("follow_up_at > ?", Time.current).order(:follow_up_at) }
  scope :overdue,      -> { follow_ups.where("follow_up_at <= ?", Time.current).order(:follow_up_at) }

  after_create :touch_contact_last_contacted

  private

  def touch_contact_last_contacted
    contact.touch_last_contacted!
  end
end
