# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'gem_support_for_new_rails')

Rails::Initializer.run do |config|
  config.gem 'exception_notification', :version => '2.3.3.0'
  config.gem 'hpricot', :version => "0.8.2" 
  config.gem 'haml', :version => "2.2.13" 
  config.gem 'action_mailer_tls', :lib => false
  config.gem 'activemerchant', :lib => 'active_merchant', :version => "1.4.2"
  config.gem 'devise', :version => "0.6.2"
  config.gem 'acts_as_audited', :lib => false, :version => "1.1.0"
  config.gem "nested_layouts", :source => "http://gemcutter.org" 
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org/'
  config.gem 'active_hash', :version => '0.8.2'
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update :default => '%Y-%m-%d %H:%M:%S'
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.update :default => '%m-%d-%Y'


ActiveMerchant::Billing::CreditCard.require_verification_value = true
# PAYMENT_RECURRING_AMOUNT = 100
# PROFESSIONAL_PLAN_AMOUNT = "#{PAYMENT_RECURRING_AMOUNT / 100}.00"
