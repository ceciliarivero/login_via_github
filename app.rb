# encoding: utf-8

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
  secret: ENV.fetch("APP_SECRET")

Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer

Cuba.use Rack::Static,
  urls: %w[/js /css /img],
  root: "./public"

Cuba.define do
  persist_session!

  on "welcome" do
    on param('code') do |code|
      response = Requests.request('POST', ENV.fetch("GITHUB_OAUTH_URL"),
        data: { client_id: ENV.fetch("GITHUB_CLIENT_ID"),
                client_secret: ENV.fetch("GITHUB_CLIENT_SECRET"),
                code: code },
        headers: { 'Accept' => 'application/json'})

      access_token = JSON.parse(response.body)["access_token"]

      user = Requests.request('GET', ENV.fetch("GITHUB_API_USER"),
        params: { access_token: access_token })
      res.write JSON.parse(user.body)["login"] #=>ceciliarivero
    end
  end

  on root do
    res.write mote("views/layout.mote",
      content: mote("views/home.mote"))
  end
end