class OfferPolicy < ApplicationPolicy
  def index?  = member?
  def show?   = buyer? || seller?
  def create? = member?
  def new?    = create?

  def accept?  = seller? && record.pending?
  def counter? = (buyer? || seller?) && record.active?
  def decline? = seller? && record.active?
  def withdraw? = buyer? && record.active?

  # Offers are not updated/destroyed directly — actions via named methods above.
  def update?  = false
  def destroy? = false

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
