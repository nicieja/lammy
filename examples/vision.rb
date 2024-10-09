# frozen_string_literal: true

class Image
  # To be able to make LLM calls, we first include `L` at the top of our class
  include L

  attr_accessor :file

  llm(model: 'claude-3-5-sonnet-20240620')
  def describe
    # We use the `L.user` notation to provide an image to the model
    L.user('Describe this image.', image: file)
  end
end

image = Image.new
image.file = File.read('./examples/assets/ruby.jpg')

puts image.describe

# => "The image is an illustration of a red gem, specifically a ruby. The gem is depicted with facets that reflect
# light, giving it a shiny and polished appearance. This image is often associated with the Ruby programming language
# logo."
