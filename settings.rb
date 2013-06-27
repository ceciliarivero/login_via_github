module Settings
  File.read("env.sh").scan(/(.*?)="?(.*)"?$/).each do |key, value|
    ENV[key] ||= value
  end

  APP_SECRET      = ENV["APP_SECRET"]
  CLIENT_ID       = ENV["CLIENT_ID"]
  CLIENT_SECRET   = ENV["CLIENT_SECRET"]
end
