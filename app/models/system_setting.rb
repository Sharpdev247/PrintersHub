class SystemSetting < ApplicationRecord
  audited

  CACHE_KEY_PREFIX = "system_setting:"
  CACHE_TTL        = 5.minutes

  VALUE_TYPES = %w[string integer float boolean json].freeze

  CATEGORIES = %w[
    general
    marketplace
    commerce
    email
    security
    api
    maintenance
  ].freeze

  validates :key,        presence: true, uniqueness: true,
                         format: { with: /\A[a-z0-9_.]+\z/,
                                   message: "only lowercase letters, numbers, dots, underscores" }
  validates :value_type, inclusion: { in: VALUE_TYPES }
  validates :category,   inclusion: { in: CATEGORIES }

  after_save    { self.class.bust_cache(key) }
  after_destroy { self.class.bust_cache(key) }

  # ── Read API ─────────────────────────────────────────────────────────────────

  def self.get(key, default: nil)
    cached = Rails.cache.fetch("#{CACHE_KEY_PREFIX}#{key}", expires_in: CACHE_TTL) do
      find_by(key: key)
    end
    cached ? cached.typed_value : default
  end

  # Batch fetch — avoids N+1 on pages that read many settings.
  def self.get_all(category: nil)
    scope = category ? where(category: category) : all
    scope.each_with_object({}) do |setting, hash|
      hash[setting.key] = setting.typed_value
    end
  end

  def self.set(key, value, value_type: nil, category: "general", description: nil)
    setting = find_or_initialize_by(key: key)
    setting.value       = value.to_s
    setting.value_type  = value_type || infer_type(value)
    setting.category    = category
    setting.description = description if description
    setting.save!
    setting
  end

  def self.bust_cache(key)
    Rails.cache.delete("#{CACHE_KEY_PREFIX}#{key}")
  end

  # ── Typed value ──────────────────────────────────────────────────────────────

  def typed_value
    return nil if value.nil?

    case value_type
    when "integer" then value.to_i
    when "float"   then value.to_f
    when "boolean" then value.in?(%w[true 1 yes])
    when "json"    then JSON.parse(value) rescue value
    else value
    end
  end

  def self.infer_type(val)
    case val
    when Integer then "integer"
    when Float   then "float"
    when TrueClass, FalseClass then "boolean"
    when Hash, Array then "json"
    else "string"
    end
  end
  private_class_method :infer_type
end
