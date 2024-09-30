# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'lammy'
  s.version = '0.1.1'
  s.summary = 'Lammy'
  s.description = 'An LLM library for Ruby'
  s.authors = ['Kamil Nicieja']
  s.email = 'kamil@nicieja.co'
  s.homepage = 'https://github.com/nicieja/lammy'
  s.license = 'MIT'

  s.add_runtime_dependency 'hashie', ['~> 5.0']
  s.add_runtime_dependency 'ruby-openai', ['~> 7.1']

  s.files = [
    'lib/lammy.rb',
    'lib/lammy/embeddings.rb',
    'lib/lammy/openai.rb',
    'lib/lammy/schema.rb',
    'lib/lammy/chat.rb'
  ]
end
