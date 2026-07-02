class OrderPolicy < ApplicationPolicy
  def index?  = member?
  def show?   = buyer? || seller? || admin?

  # Orders are created via checkout — not a manual form action.
  def create?  = member?
  def new?     = create?

  # Sellers update status / add tracking; admins can edit anything.
  def update?  = seller? || admin?
  def edit?    = update?

  # Orders are never destroyed.
  def destroy? = false

  def cancel?  = (buyer? || seller?) && record.cancellable?
  def refund?  = seller? || admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(
        "buyer_account_id = ? OR seller_account_id = ?",
        Current.account&.id, Current.account&.id
      )
    end
  end

  private

  def buyer?
    record.buyer_account_id == account&.id
  end

  def seller?
    record.seller_account_id == account&.id
  end
end
