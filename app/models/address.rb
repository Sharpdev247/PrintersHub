class Address < ApplicationRecord
  # Polymorphic: any model that does `has_many :addresses, as: :addressable` plugs in
  belongs_to :addressable, polymorphic: true, touch: true

  # Optional FKs — the DB CHECK chk_addresses_has_country enforces that at least
  # one of (country_id, country_code) is present; Rails optional: true keeps the
  # model from adding a redundant "must exist" validation on top of that.
  belongs_to :country, optional: true
  belongs_to :state,   optional: true
  belongs_to :city,    optional: true

  ADDRESS_TYPES = %w[billing shipping default other].freeze

  validates :line1,        presence: true, length: { maximum: 200 }
  validates :postal_code,  presence: true, length: { maximum: 20 }
  validates :address_type, presence: true, inclusion: { in: ADDRESS_TYPES }
  validates :latitude,  numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90  }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
  validates :country_code, format: { with: /\A[A-Z]{2}\z/, message: "must be a 2-letter ISO country code" },
                           allow_blank: true

  # Legacy freeform strings for external/unstructured data — no collision with associations
  validates :city_name,  length: { maximum: 100 }, allow_blank: true
  validates :state_name, length: { maximum: 100 }, allow_blank: true

  validate :country_reference_present
  validate :state_matches_country,  if: -> { country_id.present? && state_id.present? }
  validate :city_matches_state,     if: -> { state_id.present? && city_id.present? }

  scope :primary,      -> { where(is_primary: true) }
  scope :for_type,     ->(type) { where(address_type: type) }
  scope :billing,      -> { for_type("billing") }
  scope :shipping,     -> { for_type("shipping") }
  scope :normalised,   -> { where.not(country_id: nil) }
  scope :legacy,       -> { where(country_id: nil) }

  before_save :ensure_single_primary, if: :is_primary?

  def full_address
    # Prefer FK-resolved names; fall back to the renamed legacy string columns
    parts = [
      line1,
      line2,
      city_id.present?    ? city&.name    : city_name,
      state_id.present?   ? state&.name   : state_name,
      postal_code,
      country_id.present? ? country&.iso2 : country_code
    ]
    parts.compact_blank.join(", ")
  end

  def resolved_country_name
    country&.name || country_code
  end

  def resolved_state_name
    state&.name || state_name
  end

  def resolved_city_name
    city&.name || city_name
  end

  private

  def country_reference_present
    return if country_id.present? || country_code.present?
    errors.add(:base, "must have either a country reference or a country code")
  end

  # Ensures state belongs to the selected country
  def state_matches_country
    return unless state.present?
    unless state.country_id == country_id
      errors.add(:state, "does not belong to the selected country")
    end
  end

  # Ensures city belongs to the selected state
  def city_matches_state
    return unless city.present?
    unless city.state_id == state_id
      errors.add(:city, "does not belong to the selected state")
    end
  end

  def ensure_single_primary
    self.class
        .where(addressable: addressable, is_primary: true)
        .where.not(id: id)
        .update_all(is_primary: false)
  end
end
