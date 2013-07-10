class Login < Scrivener
  attr_accessor :github_id,:username, :name, :email

  def validate
    assert(User.fetch(github_id).nil?, [:github_id, :not_unique])
  end
end
