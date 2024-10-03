# frozen_string_literal: true

module L
  module Chat
    def llm(**kwargs)
      @next_llm_settings = kwargs
    end

    def handle_llm(method_name)
      settings = @next_llm_settings
      @next_llm_settings = nil

      # Unbind the original method
      original_method = instance_method(method_name)

      # Redefine the method
      define_method(method_name) do |*args, &block|
        # Initialize context
        @system_message = nil
        @prefilled_message = nil

        # `context` sets the system message and is available within the instance
        define_singleton_method(:context) do |message|
          @system_message = message
        end

        # `prefill` sets the prefilled message and is available within the instance
        define_singleton_method(:prefill) do |message|
          @prefilled_message = message
        end

        # Call the original method to get the user message
        user_message = original_method.bind(self).call(*args, &block)

        client = case settings[:model]
                 when *OpenAI::MODELS
                   OpenAI.new(settings)
                 when *Claude::MODELS
                   Claude.new(settings)
                 else
                   raise "Unsupported model: #{settings[:model]}"
                 end

        client.chat(user_message, @system_message, @prefilled_message)
      end
    end
  end
end
