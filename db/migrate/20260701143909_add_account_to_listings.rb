# Adds account-level ownership to listings.
#
# account_id — the Account (business) that posted this listing.
#   The existing user_id remains as the "posted by" user (creator).
#   This allows queries like "all listings by HP Faisalabad account"
#   without JOINing through users.
#
# Nullable initially to allow data migration via seeds.
# FK RESTRICT: cannot delete an account that has listings.
class AddAccountToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :account_id, :bigint

    add_foreign_key :listings, :accounts, column: :account_id, on_delete: :restrict

    # Primary query: all listings for an account, filtered by status.
    add_index :listings, [:account_id, :status],
              where: "account_id IS NOT NULL",
              name: "index_listings_on_account_and_status"
  end
end
