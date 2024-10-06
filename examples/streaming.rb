# frozen_string_literal: true

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

class Bot
  include L

  attr_reader :chat

  def initialize
    @chat = ::Chat.new
  end

  llm(model: 'gpt-4o')
  def talk(message)
    chat.messages << Message.new(:user, message)
    chat.messages << Message.new(:assistant, '')

    stream lambda { |content|
      chat.messages.last.content += content if content
      puts content
    }

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
