class PurchaseOrderPolicy < ApplicationPolicy
  def index?   = member? && (manager? || accountant?)
  def show?    = own_record?
  def create?  = own_record? && manager?
  def new?     = create?
  def update?  = own_record? && manager?
  def edit?    = update?
  def destroy? = own_record? && admin? && record.draft?

  def approve? = own_record? && admin?
  def receive? = own_record? && (manager? || warehouse_staff?)

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account: Current.account)
    end
  end
end
