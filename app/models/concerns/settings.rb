module Settings
  module_function

  # ── General ─────────────────────────────────────────────────────────────────
  def platform_name        = get("platform.name",             default: "PrintersHub")
  def support_email        = get("platform.support_email",    default: "support@printershub.com")
  def default_currency     = get("platform.default_currency", default: "USD")
  def default_timezone     = get("platform.default_timezone", default: "UTC")

  # ── Marketplace ─────────────────────────────────────────────────────────────
  def listings_per_page    = get("marketplace.listings_per_page",      default: 24)
  def max_images_per_listing = get("marketplace.max_images_per_listing", default: 10)
  def offer_max_rounds     = get("marketplace.offer_max_rounds",       default: 5)
  def offer_expiry_hours   = get("marketplace.offer_expiry_hours",     default: 48)
  def registration_open?   = get("marketplace.registration_open",      default: true)

  # ── Commerce ────────────────────────────────────────────────────────────────
  def platform_fee_pct     = get("commerce.platform_fee_pct",      default: 0.05)
  def auto_complete_days   = get("commerce.auto_complete_days",     default: 7)
  def min_order_amount     = get("commerce.min_order_amount",       default: 1.0)

  # ── Security ────────────────────────────────────────────────────────────────
  def max_login_attempts   = get("security.max_login_attempts",     default: 5)

  # ── API ─────────────────────────────────────────────────────────────────────
  def api_enabled?         = get("api.enabled",                     default: true)
  def api_rate_limit       = get("api.rate_limit_per_minute",       default: 60)
  def api_max_tokens       = get("api.max_tokens_per_user",         default: 10)

  # ── Maintenance ─────────────────────────────────────────────────────────────
  def maintenance_mode?    = get("maintenance.mode",                default: false)
  def maintenance_message  = get("maintenance.message",             default: "Scheduled maintenance in progress.")

  # ── Raw access ──────────────────────────────────────────────────────────────
  def get(key, default: nil)
    SystemSetting.get(key, default: default)
  end

  def set(key, value, **opts)
    SystemSetting.set(key, value, **opts)
  end
end
