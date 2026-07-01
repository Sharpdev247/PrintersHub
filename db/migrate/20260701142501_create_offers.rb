# Offers — price proposals from buyers on listings.
#
# Why buyer_id and seller_id are both stored:
#   seller_id is denormalized from listing.user_id at creation time. This means:
#   1. Seller queries ("show me all offers I received") don't require a JOIN to listings.
#   2. If a listing is transferred or the seller column changes, historical offers
#      still correctly record who the seller was at offer time.
#
# proposed_by_id — who made THIS specific offer in a negotiation chain.
#   In a counter-offer chain, buyer and seller take turns proposing amounts.
#   Storing proposed_by makes round attribution unambiguous regardless of chain depth.
#
# parent_offer_id — links counter-offers into a negotiation chain.
#   Nullable self-referential FK. Root offers have parent_offer_id = nil.
#   Counter-offer → parent_offer_id → original offer.
#   NULLIFY on delete: if a parent offer is hard-deleted, the chain is broken
#   gracefully (counter still has its own record).
#
# Status enum values stored explicitly:
#   0=pending, 1=accepted, 2=rejected, 3=countered, 4=withdrawn, 5=expired
#
# FK strategies:
#   listing → RESTRICT : can't delete a listing that has active offers
#   buyer   → RESTRICT : preserve offer history even if account is deactivated
#   seller  → RESTRICT : same reasoning
class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :listing,     null: false, foreign_key: { on_delete: :restrict }
      t.bigint     :buyer_id,    null: false
      t.bigint     :seller_id,   null: false
      t.bigint     :proposed_by_id, null: false
      t.bigint     :parent_offer_id               # nullable: self-referential chain
      t.decimal    :amount,      null: false, precision: 12, scale: 2
      t.string     :currency,    null: false, default: "USD", limit: 3
      t.integer    :status,      null: false, default: 0
      t.text       :message
      t.datetime   :expires_at
      t.timestamps
    end

    # FK declarations for non-references bigint columns.
    add_foreign_key :offers, :users, column: :buyer_id,       on_delete: :restrict
    add_foreign_key :offers, :users, column: :seller_id,      on_delete: :restrict
    add_foreign_key :offers, :users, column: :proposed_by_id, on_delete: :restrict
    add_foreign_key :offers, :offers, column: :parent_offer_id, on_delete: :nullify

    # Primary marketplace query patterns.
    add_index :offers, [:listing_id, :status], name: "index_offers_on_listing_and_status"
    add_index :offers, [:buyer_id,   :status], name: "index_offers_on_buyer_and_status"
    add_index :offers, [:seller_id,  :status], name: "index_offers_on_seller_and_status"

    # Partial index: negotiation chains — only rows that are counter-offers.
    add_index :offers, :parent_offer_id, where: "parent_offer_id IS NOT NULL",
              name: "index_offers_on_parent_offer_id"

    # Expiry sweep job: "find all pending offers past their expiry time".
    add_index :offers, :expires_at, where: "expires_at IS NOT NULL AND status = 0",
              name: "index_offers_on_expires_at_pending"

    # DB-level CHECK constraints.
    add_check_constraint :offers, "amount > 0",
                         name: "chk_offers_amount_positive"
    add_check_constraint :offers, "currency ~ '^[A-Z]{3}$'",
                         name: "chk_offers_currency_format"
    add_check_constraint :offers, "buyer_id <> seller_id",
                         name: "chk_offers_buyer_not_seller"
  end
end
