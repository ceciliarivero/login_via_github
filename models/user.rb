class User < Ohm::Model
  include Shield::Model

  attribute :username
  attribute :github_id
  attribute :name
  attribute :email

  unique :github_id

  def self.fetch(identifier)
    with(:github_id, identifier)
  end
end
