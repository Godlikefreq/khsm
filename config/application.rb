require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KhsmNew
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.i18n.default_locale = :ru
    config.i18n.locale = :ru
    config.i18n.fallbacks = [:en]

    config.time_zone = 'Moscow'

    config.generators do |g|
      g.test_framework :rspec,
                       request_specs: true,
                       view_specs: true,
                       routing_specs: true,
                       helper_specs: true,
                       controller_specs: true
    end
  end
end
