class Address < ApplicationRecord
  # Polymorphic: any model that does `has_many :addresses, as: :addressable` plugs in
  belongs_to :addressable, polymorphic: true, touch: true

  ADDRESS_TYPES = %w[billing shipping default other].freeze

  validates :line1,       presence: true, length: { maximum: 200 }
  validates :city,        presence: true, length: { maximum: 100 }
  validates :state,       presence: true, length: { maximum: 100 }
  validates :postal_code, presence: true, length: { maximum: 20 }
  validates :country_code, presence: true,
                           format: { with: /\A[A-Z]{2}\z/, message: "must be a 2-letter ISO country code" }
  validates :address_type, presence: true, inclusion: { in: ADDRESS_TYPES }
  validates :latitude,  numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90  }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  scope :primary,      -> { where(is_primary: true) }
  scope :for_type,     ->(type) { where(address_type: type) }
  scope :billing,      -> { for_type("billing") }
  scope :shipping,     -> { for_type("shipping") }

  before_save :ensure_single_primary, if: :is_primary?

  def full_address
    [ line1, line2, city, state, postal_code, country_code ].compact_blank.join(", ")
  end

  private

  # When marking an address primary, demote all other addresses for the same owner
  def ensure_single_primary
    self.class
        .where(addressable: addressable, is_primary: true)
        .where.not(id: id)
        .update_all(is_primary: false)
  end
end
