class CreateContactNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_notes do |t|
      t.bigint   :contact_id, null: false
      t.bigint   :author_id,  null: false
      t.text     :body,       null: false
      t.string   :note_type,  limit: 20, default: "note"  # note | call | email | meeting | follow_up
      t.datetime :follow_up_at

      t.timestamps
    end

    add_index :contact_notes, :contact_id
    add_index :contact_notes, :author_id
    add_index :contact_notes, :follow_up_at, where: "follow_up_at IS NOT NULL"

    add_foreign_key :contact_notes, :contacts
    add_foreign_key :contact_notes, :users, column: :author_id
  end
end
