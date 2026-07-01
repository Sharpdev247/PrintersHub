class Role < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :slug, presence: true, uniqueness: true

  # Normalise name before save so "Buyer" and "buyer" are treated as the same role
  before_validation :normalise_name

  private

  def normalise_name
    self.name = name.to_s.strip.downcase
  end
end
