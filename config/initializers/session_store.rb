Rails.application.config.session_store :cookie_store,
  key:      "_printershub_session",
  secure:   Rails.env.production?,  # HTTPS-only in prod
  httponly: true,                   # no JS access to session cookie
  same_site: :lax,                  # CSRF protection; allows top-level nav
  expire_after: 8.hours
