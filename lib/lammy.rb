# frozen_string_literal: true

require 'lammy/embeddings'
require 'lammy/claude'
require 'lammy/openai'
require 'lammy/schema'
require 'lammy/chat'

module L
  extend Schema

  def self.included(base)
    base.extend ClassMethods
  end

  # Wrap generative methods with handlers
  module ClassMethods
    def llm(**kwargs)
      @next_llm_settings = kwargs
    end

    def v(**kwargs)
      @next_v_settings = kwargs
    end

    def method_added(method_name)
      if @next_llm_settings
        next_llm_settings = @next_llm_settings
        @next_llm_settings = nil

        Lammy::Chat.handle(self, method_name, next_llm_settings)
      end

      if @next_v_settings
        next_v_settings = @next_v_settings
        @next_v_settings = nil

        Lammy::Embeddings.handle(self, method_name, next_v_settings)
      end

      super
    end
  end
end
