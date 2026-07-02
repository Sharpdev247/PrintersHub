class Contact < ApplicationRecord
  include Discard::Model
  audited associated_with: :account

  belongs_to :account
  belongs_to :owner, class_name: "User", optional: true
  has_many   :contact_notes, dependent: :destroy

  TYPES    = %w[contact lead customer].freeze
  STATUSES = %w[active inactive archived].freeze
  SOURCES  = %w[website referral walk_in event marketplace other].freeze
  NOTE_TYPES = %w[note call email meeting follow_up].freeze

  validates :first_name,    presence: true, length: { maximum: 100 }
  validates :last_name,     length: { maximum: 100 }, allow_blank: true
  validates :email,         format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :contact_type,  inclusion: { in: TYPES }
  validates :status,        inclusion: { in: STATUSES }

  scope :active,    -> { kept.where(status: "active") }
  scope :leads,     -> { kept.where(contact_type: "lead") }
  scope :customers, -> { kept.where(contact_type: "customer") }
  scope :recent,    -> { order(created_at: :desc) }
  scope :due_follow_up, -> {
    kept.joins(:contact_notes)
        .where("contact_notes.follow_up_at <= ? AND contact_notes.follow_up_at IS NOT NULL", Time.current)
        .distinct
  }

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def display_name
    company_name.present? ? "#{full_name} (#{company_name})" : full_name
  end

  def touch_last_contacted!
    update_column(:last_contacted_at, Time.current)
  end
end
