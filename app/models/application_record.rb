class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  RANSACK_SENSITIVE_COLUMNS = %w[
    encrypted_password reset_password_token confirmation_token unlock_token
    token_digest password_digest
  ].freeze

  def self.ransackable_attributes(_auth_object = nil)
    column_names - RANSACK_SENSITIVE_COLUMNS
  end

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end
end
