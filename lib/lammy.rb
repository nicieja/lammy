# frozen_string_literal: true

require 'lammy/embeddings'
require 'lammy/openai'
require 'lammy/schema'
require 'lammy/chat'

# Example:
#
# ```ruby
# class User < ApplicationRecord
#   include L
#
#   llm(model: 'gpt-4o')
#   def welcome
#     context "You are a helpful assistant that writes in lower case."
#     "Say hello to #{name.reverse} with a poem."
#   end
#
#   v(model: 'text-embedding-3-large')
#   def embeddings
#     chunk_by_size 256
#     welcome
#   end
# end
#
# user = User.new(name: 'John Doe')
# user.welcome
#
# # => "hello eoD nhoJ, let's make a cheer,\n
# # with a whimsical poem to bring you near.\n
# # though your name's in reverse, it’s clear and bright,\n
# # let's dance in verse on this delightful night.\n\n
# #
# # to a friend unique, in every single way,\n
# # we flip the letters but the bond will stay.\n
# # the sun may set and rise again,\n
# # with you, the fun will never wane.\n\n
# #
# # through twists and turns, in backwards flow,\n
# # we celebrate you in this poetic show.\n
# # eoD nhoJ, here's a cheer to you,\n
# # in every form, our friendship's true!"
# ```
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
