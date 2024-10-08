# frozen_string_literal: true

class User
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_reader :name

  def initialize(name:)
    @name = name
  end

  # Use the decorator to choose the model
  llm(model: 'claude-3-5-sonnet-20240620')
  def welcome
    context 'You are an AI that only writes in lower case.' # An optional system message

    # Provide a list of messages to the model for back-and-forth conversation
    [
      L.user("Say hello to #{name.reverse} with a poem."), # User message goes here
      L.assistant("here's a little poem for you:") # When using Claude, you have the ability to guide its responses by prefilling it
    ]
  end
end

user = User.new(name: 'John Doe')

puts user.welcome
