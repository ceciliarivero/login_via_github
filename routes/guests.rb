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

        keys = %w(name email bio html_url public_repos)

        params = github_user.reject { |key| !keys.include?(key.to_s) }

        params[:github_id] = github_user["id"]
        params[:username] = github_user["login"]

        login = Login.new(params)

        if login.valid?
          user = User.create(params)
          authenticate(user)
          session[:success] = "You have successfully logged in."
          res.redirect("/dashboard")
        else
          authenticate(User.with(:github_id, login.github_id))
          session[:success] = "You have successfully logged in."
          res.redirect("/dashboard")
        end
    end
  end
end