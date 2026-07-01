# One profile per user. Separating profile data from auth data keeps the users
# table narrow and lets the profile grow without touching Devise columns.
class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      # Unique FK — cascade delete so orphaned profiles cannot exist
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }

      # NOT NULL enforced at DB level as well as model layer
      t.string :first_name, null: false
      t.string :last_name,  null: false

      # Nullable — provided over time, not at registration
      t.string :phone
      t.text   :bio
      t.date   :date_of_birth

      # Default values mean app code never needs nil checks for these fields
      t.string :locale,   null: false, default: "en",  limit: 10
      t.string :timezone, null: false, default: "UTC", limit: 64

      t.timestamps
    end

    # Partial index: phone lookups are fast and NULL rows are excluded
    add_index :profiles, :phone, where: "phone IS NOT NULL"
  end
end
