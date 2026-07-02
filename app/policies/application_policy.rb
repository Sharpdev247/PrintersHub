class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user   = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class}#resolve is not implemented"
    end

    private

    attr_reader :user, :scope
  end

  private

  # Current account context — set via Current.account in controllers.
  def account
    Current.account
  end

  # Membership role for the current user in the current account.
  def membership
    @membership ||= user.memberships.kept.find_by(account: account)
  end

  def member?
    membership.present?
  end

  def owner?
    membership&.role_owner?
  end

  def admin?
    membership&.role_admin? || owner?
  end

  def manager?
    membership&.role_manager? || admin?
  end

  def sales?
    membership&.role_sales? || manager?
  end

  def technician?
    membership&.role_technician? || manager?
  end

  def warehouse_staff?
    membership&.role_warehouse_staff? || manager?
  end

  def accountant?
    membership&.role_accountant? || admin?
  end

  # Record belongs to the current account.
  def own_record?
    record.respond_to?(:account_id) && record.account_id == account&.id
  end
end
