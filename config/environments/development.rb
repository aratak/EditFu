# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = false
config.action_controller.perform_caching             = false
config.time_zone = 'Kyev'

BASE_DOMAIN = 'gryadka.com'

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.delivery_method = :smtp
config.action_mailer.default_url_options = { :host => "#{BASE_DOMAIN}:3000" }

ActiveMerchant::Billing::Base.mode = :test
PAYMENT_GATEWAY_NAME = 'authorize_net'
PAYMENT_GATEWAY_OPTS = { 
  :login => '5m7cmanV9SJ', :password => '5r9gt5rCRzM8N24w', :test => true
}
