# frozen_string_literal: true

# `Chat` and `Message` could be ActiveRecord models but we're using to use POROs for simplicity
Message = Struct.new(:role, :content)

class Chat
  attr_reader :messages

  def initialize
    @messages = []
  end

  def history
    messages.map do |message|
      case message.role
      when :user then L.user(message.content)
      when :assistant then L.assistant(message.content)
      end
    end
  end
end

# This is the main class that will be used to interact with the LLM
class Bot
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_reader :chat

  def initialize
    @chat = ::Chat.new
  end

  llm(model: 'gpt-4o')
  def talk(message)
    chat.messages << Message.new(:user, message)
    # We start with an empty assistant message which will be filled in by the model later
    chat.messages << Message.new(:assistant, '')

    # Use the `stream` method to stream chunks of the response
    stream lambda { |content|
      chat.messages.last.content += content if content
      # Display the content in the console
      puts content
    }

    # We always give the model the entire history of the conversation so that it can continue from where we left off
    chat.history
  end
end

bot = Bot.new
bot.talk('Hello, how are you?')
bot.chat.history

# => [{:role=>:user, :content=>"Hello, how are you?"}, {:role=>:assistant, :content=>"Hello! I'm here and ready to help. How can I assist you today?"}]

bot.talk("What's your name?")
bot.chat.history

# => [{:role=>:user, :content=>"Hello, how are you?"},
# {:role=>:assistant, :content=>"Hello! I'm here and ready to help. How can I assist you today?"},
# {:role=>:user, :content=>"What's your name?"},
# {:role=>:assistant, :content=>"I don't have a personal name, but you can call me Assistant or whatever you'd like. How can I help you today?"}]
