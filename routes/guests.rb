class Guests < Cuba
  define do
    on "login" do
      on param("code") do |code|
        response = Requests.request("POST", GITHUB_OAUTH_URL,
          data: { client_id: GITHUB_CLIENT_ID,
                  client_secret: GITHUB_CLIENT_SECRET,
                  code: code },
          headers: { "Accept" => "application/json"})

        access_token = JSON.parse(response.body)["access_token"]

        user_info = JSON.parse((Requests.request("GET", GITHUB_API_USER,
                  params: { access_token: access_token })).body)

        params = { github_id: user_info["id"],
                  username: user_info["login"],
                  name: user_info["name"],
                  email: user_info["email"],
                  bio: user_info["bio"],
                  html_url: user_info["html_url"],
                  public_repos: user_info["public_repos"] }

        login = Login.new(params)

        if login.valid?
          user = User.create(params)
          user.save
          authenticate(user)
          session[:success] = "You have successfully logged in."
          res.redirect("/dashboard")
        elsif User.with(:github_id, login.github_id)
          authenticate(User.with(:github_id, login.github_id))
          session[:success] = "You have successfully logged in."
          res.redirect("/dashboard")
        else
          session[:error] = "There was a problem while Login in."
          res.write mote("views/layout.mote",
            content: mote("views/login.mote"))
        end
      end

      on default do
        res.redirect "https://github.com/login/oauth/authorize?client_id=#{ GITHUB_CLIENT_ID }&scope=user"
      end
    end
  end
end