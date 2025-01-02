# Configure Sidekiq worker for processing async jobs
require 'lammy/sidekiq'

# app/models/user.rb
class User < ApplicationRecord
  attribute :name, :string

  # Use the `llm` method with `async: true` to run the method asynchronously
  llm(model: 'gpt-4o', async: true)
  def welcome
    "Say hello to #{name} with a poem."
  end
end

user = User.create!(name: 'John')
puts user.welcome
# => "ea39ea2c55d568cf96032ce1"
