# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_host_app_session',
  :secret      => '0addf6447e1905f8d470d57842d026530ae77f9d9ef94bb93a18f31bb9d61577745b3970e7caf2694ec11d58e41a2448d9ab35d901e55353ce22c0e00dd3a5cd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
