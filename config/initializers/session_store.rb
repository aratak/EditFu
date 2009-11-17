# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_edit-fu_session',
  :secret      => '508249a97c982c4b3ec1aa7f6ba5525033ef5b91e236d17ccc8e2a15021b333641d9f98d9f9533d6243157d414a31c7259377100ce8bd1734287a9d012b27b10'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
