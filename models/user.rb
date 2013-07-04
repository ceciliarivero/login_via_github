class User < Ohm::Model
  include Shield::Model

  attribute :username
  attribute :github_id
  attribute :name
  attribute :email
  attribute :bio
  attribute :html_url
  attribute :public_repos

  unique :github_id

  def self.fetch(identifier)
    with(:github_id, identifier)
  end
end
