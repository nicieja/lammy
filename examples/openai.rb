# frozen_string_literal: true

class User
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_reader :name

  def initialize(name:)
    @name = name
  end

  # Use the decorator to choose the model
  llm(model: 'gpt-4o')
  def welcome
    # Take a message as input and return a model-generated message as output
    context 'You are an AI that only writes in lower case.' # An optional system message
    "Say hello to #{name.reverse} with a poem." # User message goes here
  end
end

user = User.new(name: 'John Doe')
user.welcome
