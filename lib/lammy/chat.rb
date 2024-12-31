# frozen_string_literal: true

module Lammy
  module Chat
    def self.handle(klass, method_name, settings)
      # Unbind the original method
      original_method = klass.instance_method(method_name)

      # Redefine the method
      klass.define_method(method_name) do |*args, &block|
        # Initialize context
        @system_message = nil

        # `context` sets the system message and is available within the instance
        define_singleton_method(:context) do |message|
          @system_message = message
        end

        define_singleton_method(:stream) do |proc|
          @stream = proc
        end

        # Call the original method to get the user message
        user_message = original_method.bind(self).call(*args, &block)

        model = settings[:model] || L.configuration.model
        client = case model
                 when *OpenAI::MODELS
                   OpenAI.new(settings)
                 when *Claude::MODELS
                   Claude.new(settings)
                 else
                   raise "Unsupported model: #{settings[:model]}"
                 end

        client.chat(user_message, @system_message, @stream)
      end
    end
  end
end
