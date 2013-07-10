class Guests < Cuba
  define do
    on "oauth" do
      on param("code") do |code|
        access_token = GitHub.fetch_access_token(code)

        on access_token.nil? do
          session[:error] = "There were authentication problems."
          res.redirect "/"
        end

        on default do
          res.redirect GitHub.login_url(access_token)
        end
      end

      on default do
        res.redirect GitHub.oauth_url
      end
    end

    on "login/:access_token" do |access_token|
        github_user = GitHub.fetch_user(access_token)

        keys = %w(name email bio html_url public_repos)

        params = { github_id: github_user["id"],
                  username: github_user["login"] }

        keys.each do |key|
          params[key] = github_user[key]
        end

        login = Login.new(params)

        if login.valid?
          user = User.create(params)
          authenticate(user)
          session[:success] = "You have successfully logged in."
          res.redirect "/dashboard"
        else
          authenticate(User.with(:github_id, login.github_id))
          session[:success] = "You have successfully logged in."
          res.redirect "/dashboard"
        end
    end
  end
end