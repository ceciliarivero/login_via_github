# encoding: utf-8

require "cuba"
require "mote"
require "cuba/contrib"
require "rack/protection"
require "shield"
require "requests"
require "ohm"

GITHUB_OAUTH_URL = ENV.fetch("GITHUB_OAUTH_URL")
GITHUB_CLIENT_ID = ENV.fetch("GITHUB_CLIENT_ID")
GITHUB_CLIENT_SECRET = ENV.fetch("GITHUB_CLIENT_SECRET")
GITHUB_OAUTH_LOGIN = ENV.fetch("GITHUB_OAUTH_LOGIN")
GITHUB_API_USER = ENV.fetch("GITHUB_API_USER")
APP_SECRET = ENV.fetch("APP_SECRET")
REDIS_URL = ENV.fetch("REDIS_URL")

Cuba.plugin Cuba::Mote
Cuba.plugin Mote::Helpers
Cuba.plugin Cuba::TextHelpers
Cuba.plugin Shield::Helpers

# Connect to the Redis db
Ohm.connect(url: REDIS_URL)

# Require all application files.
Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }

# Require all helper files.
Dir["./helpers/**/*.rb"].each { |rb| require rb }
Dir["./filters/**/*.rb"].each { |rb| require rb }

# Require all module files.
Dir["./lib/**/*.rb"].each { |rb| require rb }

Cuba.plugin Cuba::Helpers

Cuba.use Rack::MethodOverride
Cuba.use Rack::Session::Cookie,
  key: "login_via_github",
  secret: APP_SECRET

Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer

Cuba.use Rack::Static,
  urls: %w[/js /css /img],
  root: "./public"


Cuba.define do
  persist_session!

  on root do
    res.write mote("views/layout.mote",
      content: mote("views/home.mote"))
  end

  on authenticated(User) do
    run Users
  end

  on default do
    run Guests
  end
end
