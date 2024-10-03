class User
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_reader :name

  def initialize(name:)
    @name = name
  end

  # Take a message as input and return a model-generated message as output
  llm(model: "gpt-4o")
  def welcome
    context "You are an AI that only writes in lower case." # An optional system message
    "Say hello to #{name.reverse} with a poem." # User message goes here
  end

  # Define a structured output schema for Lammy to handle JSON responses.
  # For a single object instead of an array, use `L.to_h`.
  llm(model: "gpt-4o-2024-08-06", schema: L.to_a(name: :string, city: :string))
  def friends
    "Hallucinate a list of friends for #{name}."
  end

  # Text embeddings measure the relatedness of text strings. The response
  # will contain a list of floating point numbers, which you can extract,
  # save in a vector database, and use for many different use cases.
  v(model: "text-embedding-3-large", dimensions: 256)
  def embeddings
    %Q{
      Hi, I'm #{name}. I'm a software engineer with a passion for Ruby
      and open-source development.
    }
  end
end

user = User.new(name: "John Doe")
user.welcome
