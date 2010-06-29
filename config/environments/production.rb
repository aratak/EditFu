# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
config.time_zone = 'Eastern Time (US & Canada)'

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

BASE_DOMAIN = 'dev.editfu.com'

ActionMailer::Base.delivery_method = :smtp
config.action_mailer.default_url_options = { :host => BASE_DOMAIN }

ActiveMerchant::Billing::Base.mode = :production
PAYMENT_GATEWAY_NAME = 'authorize_net'
PAYMENT_GATEWAY_OPTS = { 
  :login => '6wXU53eCCJbd', :password => '6Cx4w83E5xrBC3sd', :test => false
}

ExceptionNotification::Notifier.exception_recipients = %w(aratak@anahoret.com)
ExceptionNotification::Notifier.sender_address = %("EditFu Error" <errors@editfu.com>)
ExceptionNotification::Notifier.email_prefix = "[EDITFU] "
