class ServiceRequest < ApplicationRecord
  include Discard::Model
  audited associated_with: :account

  belongs_to :account                                        # service provider account
  belongs_to :customer_account, class_name: "Account", optional: true
  belongs_to :assigned_to,      class_name: "User",    optional: true
  belongs_to :printer_model,    optional: true

  STATUSES = %w[pending scheduled in_progress diagnosed waiting_parts completed cancelled].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  validates :title,          presence: true, length: { maximum: 255 }
  validates :status,         inclusion: { in: STATUSES }
  validates :priority,       inclusion: { in: PRIORITIES }
  validates :request_number, presence: true, uniqueness: true
  validates :currency,       format: { with: /\A[A-Z]{3}\z/ }, allow_blank: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :final_cost,     numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :generate_request_number, on: :create

  scope :open,       -> { where.not(status: %w[completed cancelled]) }
  scope :closed,     -> { where(status: %w[completed cancelled]) }
  scope :by_status,  ->(s) { where(status: s) }
  scope :by_priority, ->(p) { where(priority: p) }
  scope :urgent,     -> { where(priority: %w[high urgent]) }
  scope :recent,     -> { order(created_at: :desc) }
  scope :overdue,    -> { open.where("scheduled_at < ?", Time.current) }

  def transition_to!(new_status, changed_by: nil)
    ts_col = "#{new_status}_at"
    attrs  = { status: new_status }
    attrs[ts_col] = Time.current if self.class.column_names.include?(ts_col)
    update!(attrs)
  end

  def open?
    !%w[completed cancelled].include?(status)
  end

  def display_priority
    priority.humanize
  end

  private

  def generate_request_number
    return if request_number.present?
    year = Time.current.strftime("%Y")
    seq  = self.class.where("request_number LIKE ?", "SR-#{year}-%").count + 1
    self.request_number = "SR-#{year}-#{seq.to_s.rjust(5, '0')}"
  end
end
