require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PrintersHub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Compile application.scss AND active_admin.scss as separate CSS bundles.
    # dartsass-rails outputs to app/assets/builds/; Propshaft fingerprints and serves from there.
    # The gem's SCSS partials are resolved automatically because dartsass includes
    # config.assets.paths as --load-path flags (which includes gem asset directories).
    config.dartsass.builds = {
      "application.scss" => "application.css",
      "active_admin.scss" => "active_admin.css"
    }

    # Suppress Dart Sass deprecation warnings from third-party gems (ActiveAdmin uses
    # legacy @import and lighten()/darken() which are deprecated in Dart Sass 2.x).
    # These are upstream issues — not errors — and the CSS compiles correctly.
    # --silence-deprecation=import: ActiveAdmin 3.5.x still uses Sass @import (upstream issue).
    # This silences the noise without hiding any errors. Remove when ActiveAdmin upgrades to @use.
    config.dartsass.build_options = [
      "--style=compressed",
      "--no-source-map",
      "--quiet-deps",
      "--silence-deprecation=import",
      "--silence-deprecation=color-functions",
      "--silence-deprecation=global-builtin"
    ]

    # Allow serialized YAML columns (used by audited gem) to round-trip Ruby date/time
    # types that Psych 4 blocks by default in safe-load mode.
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      Time,
      Date,
      DateTime,
      Symbol,
      BigDecimal
    ]

    # Configuration for the application, engines, and railties goes here.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
