class Guests < Cuba
  define do
    on "oauth" do
      on param("code") do |code|
        access_token = GitHub.fetch_access_token(code)
        res.redirect GitHub.login_url(access_token)
      end

      on default do
        res.redirect "#{ GITHUB_OAUTH_LOGIN }?client_id=#{ GITHUB_CLIENT_ID }&scope=user"
      end
    end

    on "login/:access_token" do |access_token|
        github_user = GitHub.fetch_user(access_token)

        keys = %w(name email bio html_url public_repos)

        params = { github_id: github_user["id"], username: github_user["login"] }

        keys.each do |key|
          params[key] = github_user[key]
        end

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