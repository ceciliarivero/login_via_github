module GitHub
  def self.fetch_access_token(code)
    response = Requests.request("POST", GITHUB_OAUTH_URL,
      data: { client_id: GITHUB_CLIENT_ID,
              client_secret: GITHUB_CLIENT_SECRET,
              code: code },
      headers: { "Accept" => "application/json"})

    return JSON.parse(response.body)["access_token"]
  end

  def self.login_url(access_token)
    return "/login/#{ access_token }"
  end

  def self.fetch_user(access_token)
    return JSON.parse((Requests.request("GET", GITHUB_API_USER,
          params: { access_token: access_token })).body)
  end
end