class Profile < ApplicationRecord
  # touch: true keeps user.updated_at fresh for cache invalidation
  belongs_to :user, touch: true

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name,  presence: true, length: { maximum: 100 }
  validates :locale,     presence: true, length: { maximum: 10 }
  validates :timezone,   presence: true, length: { maximum: 64 }
  validates :phone, format: { with: /\A[\d\s\+\-\(\)\.]{7,20}\z/, message: "is not a valid phone number" },
                    allow_blank: true
  validate  :date_of_birth_in_the_past, if: -> { date_of_birth.present? }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def date_of_birth_in_the_past
    errors.add(:date_of_birth, "must be in the past") if date_of_birth >= Date.current
  end
end
