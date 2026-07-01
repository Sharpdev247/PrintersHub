class State < ApplicationRecord
  belongs_to :country
  has_many :cities,    dependent: :restrict_with_error
  has_many :addresses, foreign_key: :state_id, dependent: :restrict_with_error

  before_validation :normalise_code

  validates :name, presence: true,
                   uniqueness: { scope: :country_id, case_sensitive: false,
                                 message: "already exists in this country" },
                   length: { maximum: 100 }
  validates :code, uniqueness: { scope: :country_id, case_sensitive: false,
                                 message: "already exists in this country" },
                   length: { maximum: 10 },
                   allow_blank: true

  scope :ordered,      -> { order(:name) }
  scope :for_country,  ->(country) { where(country: country) }

  def to_s
    name
  end

  private

  def normalise_code
    self.code = code.to_s.strip.upcase.presence
  end
end
