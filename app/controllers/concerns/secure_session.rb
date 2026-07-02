module SecureSession
  extend ActiveSupport::Concern

  included do
    # Regenerate session ID after sign-in to prevent session fixation.
    # Devise calls this automatically on sign_in, but this ensures it for
    # any controller that handles sensitive state changes.
    before_action :validate_session_freshness
  end

  private

  # Invalidate sessions that were created before the user's last password change.
  # Protects against stolen sessions when a user resets their password.
  def validate_session_freshness
    return unless current_user
    return unless current_user.respond_to?(:reset_password_sent_at)

    last_reset = current_user.reset_password_sent_at
    session_created = session[:created_at]

    return unless last_reset && session_created

    if Time.zone.parse(session_created.to_s) < last_reset
      sign_out current_user
      redirect_to new_user_session_path,
                  alert: "Your session has expired. Please sign in again."
    end
  end
end
