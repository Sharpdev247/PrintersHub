class CreateApiTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :api_tokens do |t|
      t.references :account, null: false, foreign_key: true, index: true
      t.references :user,    null: false, foreign_key: true, index: true

      t.string  :name,         null: false
      t.string  :token_digest, null: false
      t.string  :token_type,   null: false, default: "personal"
      t.string  :prefix,       null: false               # first 8 chars for display
      t.jsonb   :scopes,       null: false, default: []  # ["read:listings", "write:orders"]

      t.datetime :last_used_at
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps null: false
    end

    add_index :api_tokens, :token_digest, unique: true
    add_index :api_tokens, :prefix
    add_index :api_tokens, [ :account_id, :revoked_at ]
    # Partial index — active tokens only (most common lookup)
    add_index :api_tokens, :account_id,
              where: "revoked_at IS NULL",
              name: "idx_api_tokens_active_account"
  end
end
