# Lammy

Lammy is a simple LLM library for Ruby. It doesn’t treat prompts as just strings. They represent the entire code that generates the strings sent to a LLM. The abstraction also makes it easy to attach these methods directly to models, avoiding the need for boilerplate service code.

The approach is inspired by [Python's ell](https://github.com/MadcowD/ell). I haven't come across a Ruby port yet, so I decided to start experimenting on my own.

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

```ruby
class User < ApplicationRecord
  include L

  llm(model: 'gpt-4o')
  def welcome
    context "You are a helpful assistant that writes in lower case."
    "Say hello to #{name.reverse} with a poem."
  end

  v(model: 'text-embedding-3-large')
  def embeddings
    chunk_by_size 256
    welcome
  end
end

user = User.new(name: 'John Doe')
user.welcome

# => "hello eoD nhoJ, let's make a cheer,\n
# with a whimsical poem to bring you near.\n
# though your name's in reverse, it’s clear and bright,\n
# let's dance in verse on this delightful night.\n\n
#
# to a friend unique, in every single way,\n
# we flip the letters but the bond will stay.\n
# the sun may set and rise again,\n
# with you, the fun will never wane.\n\n
#
# through twists and turns, in backwards flow,\n
# we celebrate you in this poetic show.\n
# eoD nhoJ, here's a cheer to you,\n
# in every form, our friendship's true!"
```
