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

      user = User.fetch(github_user["id"])

      if user.nil?
        signup = Signup.new(github_id: github_user["id"],
                  username: github_user["login"],
                  name: github_user["name"],
                  email: github_user["email"])

        user = User.create(signup.attributes) if signup.valid?
      end

      authenticate(user)
      session[:success] = "You have successfully logged in."
      res.redirect "/dashboard"
    end
  end
end