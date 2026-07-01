class Country < ApplicationRecord
  CONTINENTS = [
    "Africa", "Antarctica", "Asia", "Europe",
    "North America", "Oceania", "South America"
  ].freeze

  # restrict_with_error gives a readable message before the DB raises a FK exception
  has_many :states, dependent: :restrict_with_error
  has_many :cities, through: :states
  has_many :addresses, foreign_key: :country_id, dependent: :restrict_with_error

  before_validation :normalise_iso_codes

  validates :name,         presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :iso2,         presence: true, uniqueness: true,
                           format: { with: /\A[A-Z]{2}\z/, message: "must be 2 uppercase letters" }
  validates :iso3,         presence: true, uniqueness: true,
                           format: { with: /\A[A-Z]{3}\z/, message: "must be 3 uppercase letters" }
  validates :currency_code, format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" },
                            allow_blank: true
  validates :continent,    inclusion: { in: CONTINENTS }, allow_blank: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :ordered,  -> { order(:display_order, :name) }
  scope :by_continent, ->(c) { where(continent: c) }

  def to_s
    name
  end

  private

  def normalise_iso_codes
    self.iso2 = iso2.to_s.strip.upcase
    self.iso3 = iso3.to_s.strip.upcase
    self.currency_code = currency_code.to_s.strip.upcase.presence
  end
end
