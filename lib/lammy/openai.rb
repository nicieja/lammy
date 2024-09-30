# frozen_string_literal: true

require 'openai'

module L
  # Use the OpenAI API's official Ruby library
  class OpenAI
    MODELS = %w[
      gpt-4o-mini gpt-4o gpt-4-turbo gpt-4 gpt-3.5-turbo gpt-4o-mini-2024-07-18 gpt-4o-2024-08-06
      gpt-4o-2024-05-13 gpt-4-turbo-preview gpt-4-turbo-2024-04-09
    ].freeze

    EMBEDDINGS = %w[
      text-embedding-3-small text-embedding-3-large text-embedding-ada-002
    ].freeze

    # Generate a response with support for structured output
    def chat(settings, user_message, system_message = nil)
      response = client.chat(
        parameters: {
          model: settings[:model], response_format: schema(settings), messages: [
            system_message ? { role: :system, content: system_message } : nil,
            { role: :user, content: user_message }
          ].compact
        }.compact
      )

      content = response.dig('choices', 0, 'message', 'content')
      settings[:schema] ? Hashie::Mash.new(JSON.parse(content)) : content
    end

    # OpenAI’s text embeddings measure the relatedness of text strings. An embedding is a vector of floating point
    # numbers. The distance between two vectors measures their relatedness. Small distances suggest high relatedness
    # and large distances suggest low relatedness.
    def embeddings(settings, chunks)
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
        type: :json_schema,
        json_schema: {
          name: :schema,
          schema: settings[:schema]
        }
      }
    end

    def client
      @client ||= ::OpenAI::Client.new(
        access_token: ENV.fetch('OPENAI_ACCESS_TOKEN')
      )
    end
  end
end
