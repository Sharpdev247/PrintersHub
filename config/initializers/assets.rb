# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Compile ActiveAdmin JS/CSS through Sprockets (Propshaft cannot process //= require manifests)
Rails.application.config.assets.precompile += %w[active_admin.js active_admin.scss]
