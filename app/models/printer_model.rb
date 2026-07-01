class PrinterModel < ApplicationRecord
  extend FriendlyId
  friendly_id :full_model_name, use: :slugged

  belongs_to :brand
  # optional: true reflects the nullable FK — categorisation can happen later
  belongs_to :category, optional: true

  has_many :listings, dependent: :nullify

  validates :name,         presence: true, length: { maximum: 150 }
  validates :slug,         presence: true, uniqueness: true
  validates :model_number, length: { maximum: 100 }, allow_blank: true
  validates :release_year, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1950,
    less_than_or_equal_to: -> { Date.current.year + 2 }
  }, allow_nil: true

  scope :current,      -> { where(discontinued: false) }
  scope :discontinued, -> { where(discontinued: true) }
  scope :ordered,      -> { joins(:brand).order("brands.name, printer_models.name") }
  scope :for_brand,    ->(brand) { where(brand: brand) }
  scope :for_category, ->(cat)   { where(category: cat) }

  def full_model_name
    [ brand&.name, name ].compact.join(" ")
  end
end
