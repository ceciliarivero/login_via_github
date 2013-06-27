# encoding: utf-8

require File.expand_path("settings", File.dirname(__FILE__))

require "cuba"
require "mote"
require "cuba/contrib"
require "rack/protection"
require "shield"
require "requests"

Cuba.plugin Cuba::Mote
Cuba.plugin Cuba::TextHelpers
Cuba.plugin Shield::Helpers

# Require all application files.
Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }

# Require all helper files.
Dir["./helpers/**/*.rb"].each { |rb| require rb }
Dir["./filters/**/*.rb"].each { |rb| require rb }

Cuba.use Rack::MethodOverride
Cuba.use Rack::Session::Cookie,
  key: "login_via_github",
  secret: Settings::APP_SECRET

Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer

Cuba.use Rack::Static,
  urls: %w[/js /css /img],
  root: "./public"

Cuba.define do
  persist_session!

  on "welcome" do
    on param('code') do |code|
      response = Requests.request('POST', 'https://github.com/login/oauth/access_token',
        data: { client_id: Settings::CLIENT_ID,
                client_secret: Settings::CLIENT_SECRET,
                code: code })

      res.write response.body
    end

    on default do
      res.write "No access token received."
    end
  end

  on root do
    res.write mote("views/layout.mote",
      content: mote("views/home.mote"))
  end
end
