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

        # Make `context` method available within the instance
        define_singleton_method(:context) do |message|
          @system_message = message
        end

        # Call the original method to get the user message
        user_message = original_method.bind(self).call(*args, &block)

        case settings[:model]
        when *OpenAI::MODELS
          client = OpenAI.new(settings)
          client.chat(user_message, @system_message)
        else
          raise "Unsupported model: #{settings[:model]}"
        end
      end
    end
  end
end
