# Lammy

Lammy is a simple LLM library for Ruby. It doesn’t treat prompts as just strings. They represent the entire code that generates the strings sent to a LLM. The abstraction also makes it easy to attach these methods directly to models, avoiding the need for boilerplate service code.

The approach is inspired by [Python’s ell](https://github.com/MadcowD/ell). I haven’t come across a Ruby port yet, so I decided to start experimenting on my own.

## Installation

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "lammy"
```

And then execute:

```bash
$ bundle install
```

### Gem install

Or install with:

```bash
$ gem install lammy
```

and require with:

```ruby
require "lammy"
```

## Usage

We currently support OpenAI's models and Anthropic's Claude. You can use any model that supports the OpenAI API or Claude. Make sure to set the `OPENAI_API_KEY` environment variable for OpenAI models or the `ANTHROPIC_API_KEY` for Claude models.

```ruby
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

# => "hello eoD nhoJ, let's make a cheer,\n
# with a whimsical poem to bring you near.\n
# though your name's in reverse, it’s clear and bright,\n
# let's dance in verse on this delightful night!"

user.friends

# => [{"name"=>"Alice Summers", "city"=>"Austin"},
#   {"name"=>"Brian Thompson", "city"=>"Denver"},
#   {"name"=>"Charlie Herrera", "city"=>"Seattle"},
#   {"name"=>"Diana Flores", "city"=>"San Francisco"},
#   {"name"=>"Eli Grant", "city"=>"New York"},
#   {"name"=>"Fiona Collins", "city"=>"Chicago"},
#   {"name"=>"George Baker", "city"=>"Los Angeles"},
#   {"name"=>"Hannah Kim", "city"=>"Miami"},
#   {"name"=>"Isaac Chen", "city"=>"Boston"},
#   {"name"=>"Jessica Patel", "city"=>"Houston"}]

user.embeddings

# => [0.123, -0.456, 0.789, ...]
# This will be the embedding vector returned by the model
```

For a more robust setup, you can configure the client directly:

```ruby
# Helicone is an open-source LLM observability platform for developers
# to monitor, debug, and optimize their apps
$helicone = OpenAI::Client.new(
  access_token: "access_token_goes_here",
  uri_base: "https://oai.hconeai.com/",
  request_timeout: 240,
  extra_headers: {
    "X-Proxy-TTL" => "43200",
    "X-Proxy-Refresh": "true",
    "Helicone-Auth": "Bearer HELICONE_API_KEY",
    "helicone-stream-force-format" => "true",
  }
)

class User
  include L

  # (...)

  llm(model: "gpt-4o", client: $helicone)
  def description
    "Describe #{name} in a few sentences."
  end
end
```
