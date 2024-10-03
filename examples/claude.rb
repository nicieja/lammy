class User
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_reader :name

  def initialize(name:)
    @name = name
  end

  # Take a message as input and return a model-generated message as output
  llm(model: "claude-3-5-sonnet-20240620")
  def welcome
    # An optional system message
    context "You are an AI that only writes in lower case."
    # When using Claude, you have the ability to guide its responses by prefilling it
    prefill "here's a little poem for you:"
    # User message goes here
    "Say hello to #{name.reverse} with a poem."
  end
end

user = User.new(name: "John Doe")
user.welcome
