# frozen_string_literal: true

require 'anthropic'
require 'hashie'

module Lammy
  # Use the Claude API's Ruby library
  class Claude
    MODELS = %w[
      claude-3-5-sonnet-20240620
      claude-3-opus-20240229 claude-3-sonnet-20240229 claude-3-haiku-20240307
      claude-2.1 claude-2.0 claude-instant-1.2
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
          model: settings[:model],
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

      @client ||= ::Anthropic::Client.new(
        access_token: ENV.fetch('ANTHROPIC_API_KEY')
      )
    end
  end
end
