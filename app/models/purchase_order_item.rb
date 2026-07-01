class PurchaseOrderItem < ApplicationRecord
  audited

  belongs_to :purchase_order
  belongs_to :product_variant
  belongs_to :inventory_item, optional: true

  validates :quantity_ordered,   numericality: { greater_than: 0 }
  validates :quantity_received,  numericality: { greater_than_or_equal_to: 0 }
  validates :unit_cost,          numericality: { greater_than_or_equal_to: 0 }
  validates :total_cost,         numericality: { greater_than_or_equal_to: 0 }
  validate  :received_lte_ordered

  before_save :compute_total_cost

  def receive!(quantity, performed_by: nil)
    target_item = resolve_inventory_item!
    target_item.receive!(
      quantity:             quantity,
      purchase_order_item:  self,
      unit_cost:            unit_cost,
      performed_by:         performed_by
    )
    increment!(:quantity_received, quantity)
    update!(inventory_item: target_item) if inventory_item_id.nil?
    purchase_order.recalculate!
  end

  def remaining_quantity
    quantity_ordered - quantity_received
  end

  def fully_received?
    quantity_received >= quantity_ordered
  end

  private

  def compute_total_cost
    self.total_cost = unit_cost * quantity_ordered if unit_cost.present?
  end

  def received_lte_ordered
    if quantity_received > quantity_ordered
      errors.add(:quantity_received, "cannot exceed quantity ordered")
    end
  end

  def resolve_inventory_item!
    return inventory_item if inventory_item.present?
    InventoryItem.find_or_create_by!(
      product_variant: product_variant,
      warehouse:       purchase_order.warehouse
    )
  end
end
