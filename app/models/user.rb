class User < ApplicationRecord
  devise :database_authenticatable,  # Core: stores hashed password, handles sign-in
         :registerable,              # Users can sign up, edit and delete their accounts
         :recoverable,               # Password reset via email token
         :rememberable,              # "Remember me" long-lived cookie
         :validatable,               # Email format + password length validation
         :confirmable,               # Requires email confirmation before first sign-in
         :lockable,                  # Locks account after failed attempts (brute-force protection)
         :trackable                  # Records sign-in count, timestamps, and IPs
end
