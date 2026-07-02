class ApiToken < ApplicationRecord
  audited

  TOKEN_PREFIX  = "phb_"
  BYTE_LENGTH   = 32  # 256 bits → 43 Base64url chars after prefix

  TOKEN_TYPES = %w[personal service webhook].freeze

  AVAILABLE_SCOPES = %w[
    read:listings   write:listings
    read:orders     write:orders
    read:inventory  write:inventory
    read:analytics
    admin
  ].freeze

  belongs_to :account
  belongs_to :user

  validates :name,         presence: true, length: { maximum: 100 }
  validates :token_digest, presence: true, uniqueness: true
  validates :token_type,   inclusion: { in: TOKEN_TYPES }
  validates :prefix,       presence: true
  validate  :expiry_in_future, on: :create
  validate  :scopes_are_valid

  scope :active,   -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :revoked,  -> { where.not(revoked_at: nil) }
  scope :expired,  -> { where("expires_at <= ?", Time.current) }

  # ── Generation ──────────────────────────────────────────────────────────────

  # Returns [token_record, raw_token]. raw_token is shown ONCE — never stored.
  def self.generate!(account:, user:, name:, token_type: "personal", scopes: [], expires_at: nil)
    raw    = "#{TOKEN_PREFIX}#{SecureRandom.urlsafe_base64(BYTE_LENGTH)}"
    digest = digest_token(raw)
    prefix = raw[0, 12]  # "phb_" + first 8 chars

    token = create!(
      account:      account,
      user:         user,
      name:         name,
      token_digest: digest,
      token_type:   token_type,
      prefix:       prefix,
      scopes:       Array(scopes),
      expires_at:   expires_at
    )

    [token, raw]
  end

  # ── Lookup ───────────────────────────────────────────────────────────────────

  def self.authenticate(raw_token)
    return nil if raw_token.blank?
    return nil unless raw_token.start_with?(TOKEN_PREFIX)

    token = active.find_by(token_digest: digest_token(raw_token))
    return nil unless token

    token.touch_last_used
    token
  end

  def self.digest_token(raw)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, raw)
  end

  # ── Instance methods ─────────────────────────────────────────────────────────

  def revoke!
    update!(revoked_at: Time.current)
  end

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def revoked?
    revoked_at.present?
  end

  def touch_last_used
    update_column(:last_used_at, Time.current)
  end

  def has_scope?(scope)
    scopes.include?("admin") || scopes.include?(scope.to_s)
  end

  def display_token
    "#{prefix}••••••••"
  end

  private

  def expiry_in_future
    return if expires_at.nil?
    errors.add(:expires_at, "must be in the future") if expires_at <= Time.current
  end

  def scopes_are_valid
    invalid = Array(scopes) - AVAILABLE_SCOPES
    errors.add(:scopes, "contains invalid scope(s): #{invalid.join(', ')}") if invalid.any?
  end
end
