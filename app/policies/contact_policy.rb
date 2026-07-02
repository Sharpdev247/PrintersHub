class ContactPolicy < ApplicationPolicy
  def index?   = member? && sales?
  def show?    = own_record? && sales?
  def create?  = own_record? && sales?
  def new?     = create?
  def update?  = own_record? && sales?
  def edit?    = update?
  def destroy? = own_record? && manager?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept.where(account: Current.account)
    end
  end
end
