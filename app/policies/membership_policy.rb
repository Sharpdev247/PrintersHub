class MembershipPolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin? || record.user_id == user.id
  def create?  = admin?
  def new?     = create?
  def update?  = admin?
  def edit?    = update?

  # Owners cannot remove themselves if last owner — enforced at model level too.
  def destroy? = admin? && record.user_id != user.id

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept.where(account: Current.account)
    end
  end
end
