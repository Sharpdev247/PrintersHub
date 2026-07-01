class Review < ApplicationRecord
  # listing  → restrict (migration): listing is evidence of the transaction
  # reviewer → restrict (migration): preserve review history
  # reviewee → restrict (migration): preserve review history
  belongs_to :listing
  belongs_to :reviewer, class_name: "User", foreign_key: :reviewer_id
  belongs_to :reviewee, class_name: "User", foreign_key: :reviewee_id

  # 0=pending, 1=published, 2=rejected
  enum :status, { pending: 0, published: 1, rejected: 2 }, prefix: true

  validates :rating,      presence: true,
                          numericality: { only_integer: true,
                                          greater_than_or_equal_to: 1,
                                          less_than_or_equal_to: 5 }
  validates :body,        length: { maximum: 2_000 }, allow_blank: true
  validates :reviewer_id, uniqueness: { scope: :listing_id,
                                        message: "has already reviewed this listing" }
  validate  :no_self_review

  scope :published, -> { where(status: statuses[:published]) }
  scope :pending,   -> { where(status: statuses[:pending]) }
  scope :for_user,  ->(user) { where(reviewee: user) }
  scope :by_rating, -> { order(rating: :desc) }

  def approve!
    update!(status: :published)
  end

  def reject!
    update!(status: :rejected)
  end

  private

  def no_self_review
    errors.add(:reviewer, "cannot review themselves") if reviewer_id == reviewee_id
  end
end
