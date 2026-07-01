class ReorderRule < ApplicationRecord
  audited

  belongs_to :inventory_item
  belongs_to :supplier, optional: true

  validates :reorder_point,    numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_quantity, numericality: { greater_than: 0 }

  scope :active,     -> { where(active: true) }
  scope :auto_order, -> { active.where(auto_order: true) }
  scope :triggered,  -> { active.joins(:inventory_item)
                              .where("inventory_items.quantity_on_hand - inventory_items.reserved_quantity <= reorder_rules.reorder_point") }

  def triggered?
    inventory_item.available_quantity <= reorder_point
  end

  def trigger!(created_by: nil)
    return unless triggered?
    update!(last_triggered_at: Time.current)
  end
end
