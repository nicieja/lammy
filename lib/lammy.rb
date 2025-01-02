# frozen_string_literal: true

module Lammy
  class Configuration
    attr_accessor :model, :client

    def initialize
      @model = nil
      @client = nil
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

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

  def _lammy_perform_now(&block)
    @_with_sync_lammy = true
    block.call
    @_with_sync_lammy = false
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
