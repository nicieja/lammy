# frozen_string_literal: true

module L
  module Embeddings
    def v(**kwargs)
      @next_v_settings = kwargs
    end

    def handle_v(method_name)
      settings = @next_v_settings
      @next_v_settings = nil

      # Unbind the original method
      original_method = instance_method(method_name)

      # Redefine the method
      define_method(method_name) do |*args, &block|
        # Initialize chunking settings
        @chunk_by_size = nil

        # Make `chunk_by_size` method available within the instance
        define_singleton_method(:chunk_by_size) do |size|
          @chunk_by_size = size
        end

        # Call the original method to get the input
        input = original_method.bind(self).call(*args, &block)

        # # Tokenize the input
        # if @chunk_by_size.blank?
        #   input = [ input ]
        # else
        #   tokenizer = Tokenizers.from_pretrained("bert-base-cased")
        #   input = tokenizer.encode(input).tokens
        # end
        input = [input]

        case settings[:model]
        when *OpenAI::EMBEDDINGS
          client = OpenAI.new
          client.embeddings(settings, input)
        else
          raise "Unsupported model: #{settings[:model]}"
        end
      end
    end
  end
end
