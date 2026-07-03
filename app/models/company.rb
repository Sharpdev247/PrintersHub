class Company < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :account
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  has_many :addresses, as: :addressable, dependent: :destroy

  enum :company_type, {
    individual:   0,
    partnership:  1,
    llc:          2,
    corporation:  3,
    other:        4
  }, prefix: true

  validates :name,     presence: true, length: { maximum: 150 }
  validates :slug,     presence: true, uniqueness: true
  validates :email,    format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website,  format: { with: /\Ahttps?:\/\/.+\z/, message: "must start with http:// or https://" }, allow_blank: true
  validates :verified, inclusion: { in: [ true, false ] }
  validate  :verified_at_consistency

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  def verify!(admin_time = Time.current)
    update!(verified: true, verified_at: admin_time)
  end

  private

  def verified_at_consistency
    if verified? && verified_at.blank?
      errors.add(:verified_at, "must be set when company is verified")
    elsif !verified? && verified_at.present?
      errors.add(:verified_at, "must be blank when company is not verified")
    end
  end
end
