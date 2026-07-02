class Current < ActiveSupport::CurrentAttributes
  attribute :account   # active tenant Account for the current request
  attribute :user      # authenticated User (mirrors current_user for non-controller code)
  attribute :request_id
  attribute :ip_address
  attribute :user_agent

  # Convenience — role of current user in current account.
  def membership
    return nil unless account && user

    @membership ||= user.memberships.kept.find_by(account: account)
  end

  def role
    membership&.role
  end

  # True if the current user holds at least the given role in the current account.
  def role?(role_name)
    user&.role?(role_name, account: account)
  end
end
