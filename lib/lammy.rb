# frozen_string_literal: true

require 'lammy/embeddings'
require 'lammy/openai'
require 'lammy/schema'
require 'lammy/chat'

module L
  extend Schema

  def self.included(base)
    base.extend Chat
    base.extend Embeddings
    base.extend ClassMethods
  end

  # Wrap generative methods with handlers
  module ClassMethods
    def method_added(method_name)
      handle_llm(method_name) if @next_llm_settings
      handle_v(method_name) if @next_v_settings
      super
    end
  end
end
