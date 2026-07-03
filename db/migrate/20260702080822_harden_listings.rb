class HardenListings < ActiveRecord::Migration[8.1]
  # Integer → string enum maps (must match model enum definitions)
  STATUS_MAP       = { 0 => "draft", 1 => "published", 2 => "sold", 3 => "archived" }.freeze
  CONDITION_MAP    = { 0 => "brand_new", 1 => "like_new", 2 => "good", 3 => "fair", 4 => "poor" }.freeze
  LISTING_TYPE_MAP = { 0 => "sale", 1 => "rental", 2 => "service", 3 => "wanted" }.freeze

  def up
    # 1. Add string shadow columns
    add_column :listings, :status_str,       :string, null: false, default: "draft"
    add_column :listings, :condition_str,    :string, null: false, default: "brand_new"
    add_column :listings, :listing_type_str, :string, null: false, default: "sale"

    # 2. Backfill from integer values
    STATUS_MAP.each       { |int, str| execute "UPDATE listings SET status_str       = '#{str}' WHERE status       = #{int}" }
    CONDITION_MAP.each    { |int, str| execute "UPDATE listings SET condition_str    = '#{str}' WHERE condition    = #{int}" }
    LISTING_TYPE_MAP.each { |int, str| execute "UPDATE listings SET listing_type_str = '#{str}' WHERE listing_type = #{int}" }

    # 3. Drop old integer columns
    remove_column :listings, :status
    remove_column :listings, :condition
    remove_column :listings, :listing_type

    # 4. Rename shadow columns to final names
    rename_column :listings, :status_str,       :status
    rename_column :listings, :condition_str,    :condition
    rename_column :listings, :listing_type_str, :listing_type

    # 5. Add soft delete column
    add_column :listings, :discarded_at, :datetime
    add_index  :listings, :discarded_at

    # 6. Make account_id NOT NULL (all existing rows already have it)
    change_column_null :listings, :account_id, false

    # 7. Add missing indexes for new string columns
    add_index :listings, :status
    add_index :listings, [ :account_id, :status ]
    add_index :listings, [ :category_id, :status ]
    add_index :listings, [ :brand_id, :status ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Cannot convert string enums back to integers safely"
  end
end
