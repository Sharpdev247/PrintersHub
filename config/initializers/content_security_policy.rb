Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline  # required by ActiveAdmin + inline auth styles
    policy.connect_src :self
    policy.frame_src   :none
    policy.base_uri    :self
    policy.form_action :self
  end

  # Nonce per request — ties inline scripts to the current session.
  config.content_security_policy_nonce_generator =
    ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
