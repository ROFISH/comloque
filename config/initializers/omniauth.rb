# Get your own Google Client ID at the Google Developer Console. (Google it!)
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], {
    :scope=>'email'
  }
end
