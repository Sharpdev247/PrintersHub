class ListingPolicy < ApplicationPolicy
  # Public browsing — anyone can see the index and published listings.
  def index?  = true
  def show?   = record.status_published? || own_record? || manager?

  # Creating a listing requires membership with at least sales role.
  def create? = member? && sales?
  def new?    = create?

  # Editing is restricted to the owning account's sales-tier+ members.
  def update? = own_record? && sales?
  def edit?   = update?

  # Hard delete — admin+ on the owning account only.
  def destroy? = own_record? && admin?

  # Soft delete (discard) — manager+ can archive a listing off the marketplace.
  def discard? = own_record? && manager?

  # Status transitions
  def publish?    = own_record? && sales?
  def unpublish?  = own_record? && sales?
  def pause?      = own_record? && sales?
  def archive?    = own_record? && manager?
  def mark_sold?  = own_record? && sales?

  # Duplicate a listing into a new draft.
  def duplicate? = own_record? && sales?

  # Feature/unfeature — admin only.
  def feature? = own_record? && admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if Current.account
        # Members of an account see all their own listings (every status)
        # plus all kept+published listings from other accounts.
        scope.kept.where(
          "account_id = ? OR status = 'published'", Current.account.id
        )
      else
        # Unauthenticated / no active account — published only.
        scope.kept.published
      end
    end
  end
end
