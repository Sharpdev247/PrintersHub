class WarehousePolicy < ApplicationPolicy
  def index?   = member? && (manager? || warehouse_staff?)
  def show?    = own_record?
  def create?  = own_record? && manager?
  def new?     = create?
  def update?  = own_record? && manager?
  def edit?    = update?
  def destroy? = own_record? && admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account: Current.account)
    end
  end
end
