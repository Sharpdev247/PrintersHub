class Message < ApplicationRecord
  # conversation → cascade (migration): thread deletion removes all messages
  # user         → restrict (migration): cannot delete a user who sent messages
  belongs_to :conversation, touch: true
  belongs_to :user

  validates :body, presence: true, length: { maximum: 10_000 }

  scope :chronological, -> { order(:created_at) }
  scope :visible,       -> { where(deleted_at: nil) }
  scope :unread,        -> { where(read_at: nil) }

  # future: has_many_attached :attachments

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end
