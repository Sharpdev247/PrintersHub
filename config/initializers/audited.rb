# audited gem serializes audit records via YAML. Rails 8 / Psych 4 defaults to
# safe-load mode, which blocks ActiveSupport::TimeWithZone and similar classes.
# Permit them so audited can round-trip timestamps correctly.
if defined?(Psych::ClassLoader)
  Psych.add_domain_type("ruby/object", "ActiveSupport::TimeWithZone") do |_type, val|
    Time.zone.parse(val.to_s)
  end
end
