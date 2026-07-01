class OrderStatusHistory < ApplicationRecord
  belongs_to :order
  belongs_to :changed_by, class_name: "User", optional: true

  validates :to_status, presence: true
  validates :source,    presence: true,
                        inclusion: { in: %w[system user webhook admin] }

  def from_status_name
    Order.statuses.key(from_status)
  end

  def to_status_name
    Order.statuses.key(to_status)
  end

  def to_s
    "#{from_status_name} → #{to_status_name} (#{source})"
  end
end
