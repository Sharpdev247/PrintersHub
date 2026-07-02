class InventoryItemPolicy < ApplicationPolicy
  def index?   = member? && (manager? || warehouse_staff?)
  def show?    = own_record? && (manager? || warehouse_staff?)
  def create?  = own_record? && manager?
  def new?     = create?
  def update?  = own_record? && (manager? || warehouse_staff?)
  def edit?    = update?
  def destroy? = own_record? && admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account: Current.account)
    end
  end
end
