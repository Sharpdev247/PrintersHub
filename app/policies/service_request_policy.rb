class ServiceRequestPolicy < ApplicationPolicy
  def index?   = member? && (manager? || technician?)
  def show?    = own_record? && (manager? || technician?)
  def create?  = own_record? && (manager? || technician?)
  def new?     = create?
  def update?  = own_record? && (manager? || technician?)
  def edit?    = update?
  def destroy? = own_record? && admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept.where(account: Current.account)
    end
  end
end
