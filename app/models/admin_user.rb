class AdminUser < ApplicationRecord
  audited

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :trackable,
         :lockable

  ROLES = %w[staff support finance operations super_admin].freeze

  validates :email,  presence: true, uniqueness: { case_sensitive: false }
  validates :role,   inclusion: { in: ROLES }
  validates :active, inclusion: { in: [true, false] }

  scope :active,       -> { where(active: true) }
  scope :super_admins, -> { where(super_admin: true) }

  def super_admin?
    super_admin == true
  end

  def display_role
    role.to_s.humanize
  end

  # Prevent deactivated admins from signing in.
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_deactivated
  end
end
