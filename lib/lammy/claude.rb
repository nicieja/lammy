# frozen_string_literal: true

require 'anthropic'
require 'hashie'

module Lammy
  # Use the Claude API's Ruby library
  class Claude
    MODELS = [
      /\Aclaude-3-5-sonnet-latest\z/,
      /\Aclaude-3-5-haiku-latest\z/,
      /\Aclaude-3-opus-latest\z/,
      /\Aclaude-3-5-sonnet-20240620\z/,
      /\Aclaude-3-5-haiku-20241022\z/,
      /\Aclaude-3-opus-20240229\z/,
      /\Aclaude-3-sonnet-20240229\z/,
      /\Aclaude-3-haiku-20240307\z/,
      /\Aclaude-2\.1\z/,
      /\Aclaude-2\.0\z/,
      /\Aclaude-instant-1\.2\z/
    ].freeze

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    # Generate a response with support for structured output
    def chat(user_message, system_message = nil, stream = nil)
      response = client.messages(
        parameters: {
          system: system_message,
          model: settings[:model] || Lammy.configuration.model,
          max_tokens: settings[:max_tokens] || 4096,
          stream: stream ? ->(chunk) { stream.call(stream_content(chunk)) } : nil,
          messages: user_message.is_a?(Array) ? user_message : [vision(L.user(user_message))]
        }.compact
      )

      stream || response.dig('content', 0, 'text')
    end

    private

    def stream_content(chunk)
      chunk.dig('delta', 'text')
    end

    def vision(message)
      image = message[:_image]
      base = message.except(:_image)

      return base unless image

      messages = [
        { 'type' => 'image',
          'source' => { 'type' => 'base64', 'media_type' => 'image/jpeg', 'data' => Base64.strict_encode64(image) } },
        { 'type' => 'text', 'text' => message[:content] }
      ]

      base.merge(content: messages)
    end

    def client
      return settings[:client] if settings[:client]
      return Lammy.configuration.client if Lammy.configuration.client

      @client ||= ::Anthropic::Client.new(
        access_token: ENV.fetch('ANTHROPIC_API_KEY')
      )
    end
  end
end
