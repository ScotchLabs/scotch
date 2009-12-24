# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_scotch_session',
  :secret      => 'e063c9dc361692f2f9c5d14cb7549623fd20ec473170a5964d7b4b72afbd11b50a7ad7f13890f16715ad29140712cb43a0a1c81421fe79162990116be676ebbf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
