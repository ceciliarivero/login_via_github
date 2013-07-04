class Users < Cuba
  define do
    on "dashboard" do
      res.write mote("views/layout.mote",
        content: mote("views/dashboard.mote"))
    end

    on "logout" do
      logout(User)
      session[:success] = "You have successfully logged out."
      res.redirect "/", 303
    end
  end
end
