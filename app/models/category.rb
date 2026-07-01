class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # ancestry gem: adds parent/children/ancestors/descendants/subtree/depth/path
  has_ancestry orphan_strategy: :restrict

  has_many :printer_models, foreign_key: :category_id, dependent: :nullify

  validates :name,     presence: true, length: { maximum: 100 }
  validates :slug,     presence: true, uniqueness: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active,    -> { where(active: true) }
  scope :inactive,  -> { where(active: false) }
  scope :ordered,   -> { order(:position, :name) }
  scope :top_level, -> { roots }

  def breadcrumb
    path.map(&:name)
  end

  def depth_label
    "#{"— " * depth}#{name}"
  end
end
