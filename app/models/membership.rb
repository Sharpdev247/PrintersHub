class Membership < ApplicationRecord
  include Discard::Model
  audited

  belongs_to :account
  belongs_to :user

  enum :role, {
    owner:           0,
    admin:           1,
    manager:         2,
    sales:           3,
    technician:      4,
    warehouse_staff: 5,
    accountant:      6
  }, prefix: true

  validates :user_id, uniqueness: { scope: :account_id,
                                    message: "is already a member of this account",
                                    conditions: -> { kept } }
  validates :role, presence: true
  validate  :account_must_have_owner_on_discard, if: :discarded?

  scope :active,   -> { kept }
  scope :owners,   -> { kept.where(role: roles[:owner]) }
  scope :by_role,  ->(r) { kept.where(role: roles[r]) }

  def display_title
    title.presence || role.to_s.humanize
  end

  private

  def account_must_have_owner_on_discard
    if role_owner? && account.memberships.kept.owners.where.not(id: id).none?
      errors.add(:base, "cannot remove the last owner of an account")
    end
  end
end
