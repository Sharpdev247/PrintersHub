class City < ApplicationRecord
  belongs_to :state
  # Traverses state -> country; allows city.country without a direct FK
  has_one :country, through: :state
  has_many :addresses, foreign_key: :city_id, dependent: :restrict_with_error

  validates :name, presence: true,
                   uniqueness: { scope: :state_id, case_sensitive: false,
                                 message: "already exists in this state" },
                   length: { maximum: 100 }
  validates :latitude,  numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90  }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  scope :ordered,    -> { order(:name) }
  scope :for_state,  ->(state) { where(state: state) }
  scope :geocoded,   -> { where.not(latitude: nil, longitude: nil) }

  def coordinates?
    latitude.present? && longitude.present?
  end

  def to_s
    name
  end
end
