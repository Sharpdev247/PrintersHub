class Brand < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :printer_models, dependent: :restrict_with_error
  has_many :listings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :website, format: { with: /\Ahttps?:\/\/.+/, message: "must start with http:// or https://" }, allow_blank: true

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :ordered,  -> { order(:name) }
end
