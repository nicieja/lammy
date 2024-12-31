# Lammy

Lammy is a simple LLM library for Ruby. It doesn't treat prompts as just strings. They represent the entire code that generates the strings sent to a LLM. The abstraction also makes it easy to attach these methods directly to models, avoiding the need for boilerplate service code.

The approach is inspired by [Python's ell](https://github.com/MadcowD/ell). I haven't come across a Ruby port yet, so I decided to start experimenting on my own.

## Why?

I wanted to create a simple library that would let me use LLMs in my Ruby projects without dealing with a lot of boilerplate code.

Using something like `langchain` felt too complex for many of my needs. Another option would be to integrate a library directly with a framework like Ruby on Rails, leveraging its conventions. You could, for example, store prompts in the database or as views. But that seemed like overkill for what I needed, and it would add a dependency on the framework, making it harder to use in simple programs.

Personally, I don't think prompt engineering needs to be that complicated, which is why the `ell` approach—treating prompts like simple functions—really resonated with me. I wanted to bring something similar to Ruby. I don’t see why LLMs can't be treated like databases in Active Record, where all the complexity is abstracted away. You can query without needing to think much about the underlying SQL. With Lammy, the idea is similar: you just define your prompt in a method on a model and call it like any other method.

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

You can find a basic example of how to use Lammy in Rails in the [lammy-rails-example](https://github.com/nicieja/lammy-rails-example) repository.

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

We currently support OpenAI's models and Anthropic's Claude. You can use any model that supports the OpenAI API or Claude. Make sure to set the `OPENAI_ACCESS_TOKEN` environment variable for OpenAI models or the `ANTHROPIC_API_KEY` for Claude models.

### Chat

Lammy allows you to interact with a chat model using the `llm` decorator. The `llm` decorator accepts a `model` argument, where you specify the name of the model you'd like to use.

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
    # User message goes here
    "Say hello to #{name.reverse} with a poem."
  end
end

user = User.new(name: "John Doe")
user.welcome

# => "Hello eoD nhoJ, let's make a cheer,\n
# With a whimsical poem to bring you near.\n
# Though your name's in reverse, it’s clear and bright,\n
# Let's dance in verse on this delightful night!"
```

### System message

You can provide a system message to the model through the `context` method. This is an optional approach that allows you to give the model additional context. We chose not to use the `system` method because it's a potentially risky Ruby method.

```ruby
class User
  include L

  # (...)

  llm(model: "gpt-4o")
  def welcome
    # An optional system message
    context "You are an AI that only writes in lower case."
    # User message goes here
    "Say hello to #{name.reverse} with a poem."
  end
end

user = User.new(name: "John Doe")
user.welcome

# => "hello eod nhoj, let's make a cheer,\n
# with a whimsical poem to bring you near.\n
# though your name's in reverse, it’s clear and bright,\n
# let's dance in verse on this delightful night!"
```

### Structured output for OpenAI's models

You can request OpenAI's models to return a structured JSON output by using the `schema` option in the decorator. This is an optional feature that allows you to define a structured output format for the model. To handle arrays of objects, use `L.to_a`, and for a single object, use `L.to_h`.

```ruby
class User
  include L

  # (...)

  # Define a structured output schema for Lammy to handle JSON responses.
  # For a single object instead of an array, use `L.to_h`.
  llm(model: "gpt-4o-2024-08-06", schema: L.to_a(name: :string, city: :string))
  def friends
    "Hallucinate a list of friends for #{name}."
  end
end

user = User.new(name: "John Doe")
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
```

### Prefilling assistant responses for Claude

Anthtopic decided to improve output consistency and implement JSON mode by allowing users to prefill the model's response. Lammy enables this feature through its array syntax, along with the `L.user` and `L.system` helper methods.

```ruby
class User
  include L

  # (...)

  llm(model: "claude-3-5-sonnet-20240620")
  def welcome
    # Provide a list of messages to the model for back-and-forth conversation
    [
      # User message goes here
      L.user("Say hello to #{name.reverse} with a poem."),
      # When using Claude, you have the ability to guide its responses by prefilling it
      L.assistant("Here's a little poem for you:")
    ]
  end
end
```

Although only Claude models prefill responses, the array syntax can be applied to both OpenAI and Claude models. For OpenAI's models, this feature is used to continue the conversation from where the previous message left off, enabling multi-message conversations like the one in our upcoming example.

### Streaming

You can use the `stream` method to stream responses from the LLM in real time, which can be much faster and help create a more engaging user experience. To receive chunks of the response as they come in, pass a lambda to the `stream` method.

```ruby
class Bot
  include L

  llm(model: "gpt-4o")
  def talk(message)
    # Use the `stream` method to stream chunks of the response.
    # In this case, we're just printing the chunks.
    stream ->(content) { puts content }
    # Nothing fancy, simply transfer the message to the model
    message
  end
end

bot = Bot.new
bot.talk("Hello, how are you?")

# => "I'm here and ready to help. How can I assist you today?"
```

This is a simplified explanation of how you can use the `stream` method. For a complete example, refer to [this file](https://github.com/nicieja/lammy/blob/main/examples/streaming.rb). This implementation allows to hold an actual conversation with the model, which is the most common use case for chatbots, and does it using Lammy's array syntax.

### Vision

You can use a vision model to generate a description of an image this way:

```ruby
class Image
  include L

  attr_accessor :file

  llm(model: "gpt-4o")
  def describe
    L.user("Describe this image.", image: file)
  end
end

image = Image.new
image.file = File.read("./examples/assets/ruby.jpg")
image.describe

# => "The image is an illustration of a red gem, specifically a ruby.
# The gem is depicted with facets that reflect light, giving it a shiny
# and polished appearance. This image is often associated with
# the Ruby programming language logo."
```

The `L.user` helper method must be used to attach the image to the prompt.

### Custom clients

For a more robust setup, you can configure the client directly and pass it to the decorator.

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

  # Pass the Helicone client to Lammy's decorator
  llm(model: "gpt-4o", client: $helicone)
  def description
    "Describe #{name} in a few sentences."
  end
end
```

### Embeddings

You can use the embeddings endpoint to obtain a vector of numbers that represents an input. These vectors can be compared across different inputs to efficiently determine their similarity. Currently, Lammy supports only OpenAI's embeddings endpoint.

```ruby
class User
  include L

  # (...)

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
user.embeddings

# => [0.123, -0.456, 0.789, ...]
# This will be the embedding vector returned by the model
```

Now you're able to store this vector in a vector database, such as `pgvector`, and use it to compare the similarity of different inputs. For example, you can use the [cosine similarity](https://en.wikipedia.org/wiki/Cosine_similarity) to determine the similarity between two vectors.

## Configuration

Lammy allows you to configure global settings using a configuration block. This is useful for setting a default model or a custom client that will be used across your application.

### Setting a global model

You can set a global LLM model that will be used by default in your application. This is done using the `configure` method:

```ruby
Lammy.configure do |config|
  config.model = "gpt-4o"
end
```

With a global model configured, you can now use the `llm` decorator without specifying the model:

```ruby
class User
  include L

  # (...)

  llm
  def welcome
    "Say hello to #{name} with a poem."
  end
end
```

### Setting a custom client

You can also set a global custom client. This is useful if you want to use a specific client configuration throughout your application:

```ruby
Lammy.configure do |config|
  config.client = OpenAI::Client.new(
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
end
```

## Versioning

Semantic versioning is used. For a version number `major.minor.patch`, unless `major` is 0:

1. `major` version is incremented when incompatible API changes are made,
2. `minor` version is incremented when functionality is added in a backwards-compatible manner,
3. `patch` version is incremented when backwards-compatible bug fixes are made.

Major version "zero" (0.y.z) is for initial development. Anything may change at any time. The public API should not be considered stable. Furthermore, version "double-zero" (0.0.x) is not intended for public use, as even minimal functionality is not guaranteed to be implemented yet.

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request

## License

Lammy is released under the MIT License.
