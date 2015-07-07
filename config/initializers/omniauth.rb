INSTALLED_LOGINS ||= {}

# Get your own Google Client ID at the Google Developer Console. (Google it!)
if ENV["GOOGLE_CLIENT_ID"].is_a?(String) && ENV["GOOGLE_CLIENT_ID"].length > 0
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], {
      :scope=>'email'
    }
  end
  INSTALLED_LOGINS['google'] = true
else
  INSTALLED_LOGINS['google'] = false
end
