# frozen_string_literal: true

require 'openai'
require 'hashie'
require 'base64'

module Lammy
  # Use the OpenAI API's Ruby library
  class OpenAI
    MODELS = [
      /^gpt-.*$/,
      /^chatgpt-.*$/,
      /^o\d+(?:-.*)?$/,
      /^(?:davinci|babbage)-002$/
    ].freeze

    EMBEDDINGS = %w[
      text-embedding-3-small text-embedding-3-large text-embedding-ada-002
    ].freeze

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    # Generate a response with support for structured output
    def chat(user_message, system_message = nil, stream = nil)
      schema = schema(settings)
      messages = messages(user_message, system_message)

      request = client.chat(
        parameters: {
          model: settings[:model] || Lammy.configuration.model,
          response_format: schema,
          messages: messages,
          stream: stream ? ->(chunk) { stream.call(stream_content(chunk)) } : nil
        }.compact
      )

      return stream if stream

      response = request.dig('choices', 0, 'message', 'content')
      content = schema ? ::Hashie::Mash.new(JSON.parse(response)) : response
      array?(schema) ? content.items : content
    end

    # OpenAI’s text embeddings measure the relatedness of text strings. An embedding is a vector of floating point
    # numbers. The distance between two vectors measures their relatedness. Small distances suggest high relatedness
    # and large distances suggest low relatedness.
    def embeddings(chunks)
      responses = chunks.map do |chunk|
        response = client.embeddings(
          parameters: { model: settings[:model], dimensions: settings[:dimensions], input: chunk }
        )

        response.dig('data', 0, 'embedding')
      end

      responses.one? ? responses.first : responses
    end

    private

    def schema(settings)
      return unless settings[:schema]

      {
        'type' => 'json_schema',
        'json_schema' => {
          'name' => 'schema',
          'schema' => settings[:schema].merge('additionalProperties' => false)
        }
      }
    end

    def messages(user_message, system_message)
      return user_message if user_message.is_a?(Array)

      [
        system_message ? L.system(system_message) : nil,
        vision(L.user(user_message))
      ].compact
    end

    def vision(message)
      image = message[:_image]
      base = message.except(:_image)

      return base unless image

      messages = [
        { 'type' => 'text', 'text' => message[:content] },
        {
          'type' => 'image_url', 'image_url' => { 'url' => "data:image/jpeg;base64,#{Base64.encode64(image)}" }
        }
      ]

      base.merge(content: messages)
    end

    def array?(schema)
      schema.is_a?(Hash) && schema.dig('json_schema', 'schema', 'properties', 'items', 'type') == 'array'
    end

    def stream_content(chunk)
      chunk.dig('choices', 0, 'delta', 'content')
    end

    def client
      return settings[:client] if settings[:client]
      return Lammy.configuration.client if Lammy.configuration.client

      @client ||= ::OpenAI::Client.new(
        access_token: ENV.fetch('OPENAI_ACCESS_TOKEN')
      )
    end
  end
end
