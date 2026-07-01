class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  # Model-level uniqueness gives a friendly error; DB unique index is the hard stop
  validates :user_id, uniqueness: { scope: :role_id, message: "already has this role" }
end
