class AdminUser < ApplicationRecord
  devise :database_authenticatable,  # Core sign-in with hashed password
         :recoverable,               # Password reset via email
         :rememberable,              # "Remember me" session
         :validatable,               # Email format + password length
         :trackable,                 # Audit every admin sign-in (count, IP, time)
         :lockable                   # Lock after failed attempts (brute-force protection)
end
