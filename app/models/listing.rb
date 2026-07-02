class Listing < ApplicationRecord
  include Discard::Model
  audited associated_with: :account

  extend FriendlyId
  friendly_id :title, use: :slugged

  include PgSearch::Model

  # Full-text + trigram search across listing content and related names.
  # Weight A: title (most relevant), B: description, C: brand/category/model names.
  pg_search_scope :search,
                  against: { title: "A", description: "B" },
                  associated_against: {
                    brand:         { name: "C" },
                    category:      { name: "C" },
                    printer_model: { name: "C" }
                  },
                  using: {
                    tsearch:  { prefix: true, dictionary: "english" },
                    trigram:  { threshold: 0.15, only: [:title] }
                  }

  belongs_to :user
  belongs_to :account
  belongs_to :product,        optional: true
  belongs_to :inventory_item, optional: true
  belongs_to :category
  belongs_to :brand
  belongs_to :printer_model, optional: true
  belongs_to :location_city, class_name: "City", foreign_key: :location_city_id, optional: true

  has_many_attached :images
  has_many_attached :documents

  # Interaction layer reverse associations
  has_many :favorites,     dependent: :destroy
  has_many :favorited_by,  through: :favorites, source: :user
  has_many :conversations, dependent: :nullify
  has_many :offers,        dependent: :restrict_with_error
  has_many :reviews,       dependent: :restrict_with_error
  has_many :cart_items,  dependent: :destroy
  has_many :order_items, dependent: :nullify
  has_many :carts,       through: :cart_items

  enum :listing_type, { sale: "sale", rental: "rental", service: "service", wanted: "wanted" }, prefix: true
  enum :condition,    { brand_new: "brand_new", like_new: "like_new", good: "good", fair: "fair", poor: "poor" }, prefix: true
  enum :status,       { draft: "draft", published: "published", sold: "sold", archived: "archived", paused: "paused" }, prefix: true

  validates :listing_type, inclusion: { in: listing_types.keys }
  validates :condition,    inclusion: { in: conditions.keys }
  validates :status,       inclusion: { in: statuses.keys }

  SUPPORTED_IMAGE_TYPES    = %w[image/jpeg image/png image/webp image/gif].freeze
  SUPPORTED_DOCUMENT_TYPES = %w[application/pdf].freeze
  MAX_IMAGE_SIZE           = 10.megabytes
  MAX_DOCUMENT_SIZE        = 20.megabytes
  MAX_IMAGES               = 20
  MAX_DOCUMENTS            = 5

  validates :title,        presence: true, length: { minimum: 5, maximum: 200 }
  validates :slug,         presence: true, uniqueness: true
  validates :description,  presence: true, length: { minimum: 20, maximum: 10_000 }
  validates :listing_type, presence: true
  validates :condition,    presence: true
  validates :price,        presence: true,
                           numericality: { greater_than: 0 }
  validates :currency,     presence: true,
                           format: { with: /\A[A-Z]{3}\z/, message: "must be a 3-letter ISO 4217 code" }
  validates :quantity,     numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :year,         numericality: { only_integer: true,
                                           greater_than_or_equal_to: 1950,
                                           less_than_or_equal_to: -> { Date.current.year + 2 } },
                           allow_nil: true
  validates :views_count,  numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :published_at_present_when_live
  validate :images_count_within_limit
  validate :documents_count_within_limit
  validate :image_content_types
  validate :image_file_sizes
  validate :document_content_types
  validate :document_file_sizes

  scope :published,    -> { kept.where(status: "published") }
  scope :draft,        -> { kept.where(status: "draft") }
  scope :sold,         -> { kept.where(status: "sold") }
  scope :archived,     -> { kept.where(status: "archived") }
  scope :paused,       -> { kept.where(status: "paused") }
  scope :featured,     -> { where(featured: true) }
  scope :live,         -> { kept.where(status: %w[published sold]) }
  scope :recent,          -> { order(published_at: :desc) }
  scope :by_price_asc,    -> { order(price: :asc) }
  scope :by_price_desc,   -> { order(price: :desc) }
  scope :by_newest,       -> { order(created_at: :desc) }
  scope :by_views,        -> { order(views_count: :desc) }
  scope :for_category,    ->(cat) { where(category: cat) }
  scope :for_brand,       ->(b)   { where(brand: b) }
  scope :price_between,   ->(min, max) { where(price: min..max) }
  scope :in_currency,     ->(c)   { where(currency: c) }
  scope :search_title,    ->(q)   { where("title ILIKE ?", "%#{sanitize_sql_like(q)}%") }

  def publish!
    update!(status: :published, published_at: published_at || Time.current)
  end

  def archive!
    update!(status: :archived)
  end

  def mark_sold!
    update!(status: :sold)
  end

  def pause!
    update!(status: :paused)
  end

  def increment_view!
    # SQL-level increment avoids lock contention and bypasses callbacks/auditing.
    self.class.where(id: id).update_all("views_count = views_count + 1")
    reload
  end

  def owned_by?(user)
    user_id == user&.id
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  private

  def published_at_present_when_live
    if (status_published? || status_sold?) && published_at.blank?
      errors.add(:published_at, "must be set when listing is published or sold")
    end
  end

  def images_count_within_limit
    return unless images.attached?
    if images.length > MAX_IMAGES
      errors.add(:images, "can have at most #{MAX_IMAGES} images")
    end
  end

  def documents_count_within_limit
    return unless documents.attached?
    if documents.length > MAX_DOCUMENTS
      errors.add(:documents, "can have at most #{MAX_DOCUMENTS} documents")
    end
  end

  def image_content_types
    images.each do |image|
      next if image.content_type.in?(SUPPORTED_IMAGE_TYPES)
      errors.add(:images, "#{image.filename} is not a supported image format (JPEG, PNG, WebP, GIF)")
    end
  end

  def image_file_sizes
    images.each do |image|
      next if image.byte_size <= MAX_IMAGE_SIZE
      errors.add(:images, "#{image.filename} is too large (max #{MAX_IMAGE_SIZE / 1.megabyte} MB)")
    end
  end

  def document_content_types
    documents.each do |doc|
      next if doc.content_type.in?(SUPPORTED_DOCUMENT_TYPES)
      errors.add(:documents, "#{doc.filename} is not a supported document format (PDF)")
    end
  end

  def document_file_sizes
    documents.each do |doc|
      next if doc.byte_size <= MAX_DOCUMENT_SIZE
      errors.add(:documents, "#{doc.filename} is too large (max #{MAX_DOCUMENT_SIZE / 1.megabyte} MB)")
    end
  end
end
