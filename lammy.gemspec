# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'lammy'
  s.version = '0.10.0'
  s.summary = 'Lammy'
  s.description = 'An LLM library for Ruby'
  s.authors = ['Kamil Nicieja']
  s.email = 'kamil@nicieja.co'
  s.homepage = 'https://github.com/nicieja/lammy'
  s.license = 'MIT'

  s.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  s.add_runtime_dependency 'anthropic', ['~> 0.3']
  s.add_runtime_dependency 'hashie', ['~> 5.0']
  s.add_runtime_dependency 'ruby-openai', ['~> 7.1']

  s.add_development_dependency 'pry', ['~> 0.14.2']

  s.files = [
    'lib/lammy.rb',
    'lib/lammy/embeddings.rb',
    'lib/lammy/openai.rb',
    'lib/lammy/claude.rb',
    'lib/lammy/schema.rb',
    'lib/lammy/chat.rb'
  ]
end
