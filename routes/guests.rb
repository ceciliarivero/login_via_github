class Guests < Cuba
  define do
    on "oauth" do
      on param("code") do |code|
        response = Requests.request("POST", GITHUB_OAUTH_URL,
          data: { client_id: GITHUB_CLIENT_ID,
                  client_secret: GITHUB_CLIENT_SECRET,
                  code: code },
          headers: { "Accept" => "application/json"})

        access_token = JSON.parse(response.body)["access_token"]

        res.redirect("/login/#{ access_token }")
      end

      on default do
        res.redirect "#{ GITHUB_OAUTH_LOGIN }?client_id=#{ GITHUB_CLIENT_ID }&scope=user"
      end
    end

    on "login/:access_token" do |access_token|
        github_user = JSON.parse((Requests.request("GET", GITHUB_API_USER,
                  params: { access_token: access_token })).body)

        params = { github_id: github_user["id"],
                  username: github_user["login"],
                  name: github_user["name"],
                  email: github_user["email"],
                  bio: github_user["bio"],
                  html_url: github_user["html_url"],
                  public_repos: github_user["public_repos"] }

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
  end
end