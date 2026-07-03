# Memberships — the user↔account junction table.
#
# Why Membership instead of a direct has_many :through?
#   Membership carries per-relationship state: role, custom title, soft-delete,
#   and future invitation metadata. It's a first-class model, not a join.
#
# role enum: 0=owner, 1=admin, 2=manager, 3=sales, 4=technician,
#            5=warehouse_staff, 6=accountant
#
# An account must always have at least one owner (enforced at model layer).
# discarded_at — soft-remove a member without destroying the user record.
# accepted_at  — future: invitation acceptance timestamp.
#
# FK strategies:
#   account → CASCADE : account deletion removes all memberships
#   user    → CASCADE : user deletion removes their memberships
class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,    null: false, foreign_key: { on_delete: :cascade }
      t.integer  :role,         null: false, default: 0
      t.string   :title,        limit: 100   # custom job title e.g. "Senior Sales Executive"
      t.datetime :accepted_at                # future: invitation flow
      t.datetime :discarded_at
      t.timestamps
    end

    # One active membership per user per account (soft-deleted ones allowed to remain)
    add_index :memberships, [ :account_id, :user_id ],
              unique: true,
              where: "discarded_at IS NULL",
              name: "index_memberships_on_account_and_user_active"

    # Admin: all members of an account by role
    add_index :memberships, [ :account_id, :role ], name: "index_memberships_on_account_and_role"

    add_index :memberships, :discarded_at,
              where: "discarded_at IS NOT NULL",
              name: "index_memberships_on_discarded_at"
  end
end
