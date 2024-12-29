# frozen_string_literal: true

class User
  include L

  attr_reader :name

  def initialize(name:)
    @name = name
  end

  # Define a structured output schema for Lammy to handle JSON responses.
  # For a single object instead of an array, use `L.to_h`.
  # You can nest objects and arrays as well.
  llm(model: "gpt-4o-2024-08-06", schema: L.to_a(name: L.to_h(first: :string, last: :string), city: :string))
  def friends
    "Hallucinate a list of friends for #{name}."
  end
end

user = User.new(name: "John Doe")
user.friends
