require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Lobsters
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Future Rails version will disable implicit joins, so we'll be prepared.
    config.active_record.disable_implicit_join_references = true

    config.cache_store = :memory_store
  end
end

# disable yaml/xml/whatever input parsing
silence_warnings do
  ActionDispatch::ParamsParser::DEFAULT_PARSERS = {}
end

# define site name and domain to be used globally, can be overridden in
# config/initializers/production.rb
class << Rails.application
  def domain
    "news.hexlet.io"
  end

  def name
    "Hexlet News"
  end

  # used as mailing list prefix and countinual prefix, cannot have spaces
  def shortname
    name.downcase.gsub(/[^a-z]/, "")
  end
end

Rails.application.routes.default_url_options[:host] = Rails.application.domain

require "#{Rails.root}/lib/monkey"
