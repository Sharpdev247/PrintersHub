# db/seeds.rb
# Idempotent — safe to run multiple times in any environment.
# Production: set ADMIN_EMAIL and ADMIN_PASSWORD as environment variables
#             before running `bin/rails db:seed`.

# ── Admin User ───────────────────────────────────────────────────────────────
admin_email    = ENV.fetch("ADMIN_EMAIL",    "admin@printershub.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "ChangeMe123!")

admin = AdminUser.find_or_initialize_by(email: admin_email)

if admin.new_record?
  admin.password              = admin_password
  admin.password_confirmation = admin_password
  admin.save!
  puts "Created admin user: #{admin_email}"
else
  puts "Admin user already exists: #{admin_email}"
end
