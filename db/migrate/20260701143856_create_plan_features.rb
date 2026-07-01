# PlanFeatures — per-plan feature configuration.
#
# feature_type enum (stored as string): "boolean" | "limit" | "string"
#   boolean → value: "true"/"false"   e.g. api_access: true
#   limit   → value: "100"/"unlimited"  e.g. max_listings: 25
#   string  → value: free text         e.g. support_level: "email"
#
# Why store value as string?
#   Avoids a polymorphic value column. Casting is done in the model.
#   "unlimited" is a sentinel value meaning no upper bound.
#
# Unique [plan_id, feature_key] ensures each feature appears once per plan.
# FK CASCADE: deleting a plan removes its features.
class CreatePlanFeatures < ActiveRecord::Migration[8.1]
  def change
    create_table :plan_features do |t|
      t.references :subscription_plan, null: false, foreign_key: { on_delete: :cascade }
      t.string :feature_key,  null: false
      t.string :feature_type, null: false, default: "boolean"
      t.string :value,        null: false
      t.string :display_name, null: false
      t.text   :description
      t.timestamps
    end

    add_index :plan_features, [:subscription_plan_id, :feature_key],
              unique: true,
              name: "index_plan_features_on_plan_and_key"

    add_check_constraint :plan_features,
                         "feature_type IN ('boolean', 'limit', 'string')",
                         name: "chk_plan_features_feature_type"
  end
end
