# frozen_string_literal: true

module L
  module Schema
    def self.formatted?(content)
      content.is_a?(Hash) && content.key?(:role) && content.key?(:content)
    end

    def system(content)
      return content if L::Schema.formatted?(content)

      { role: :system, content: content }
    end

    def user(content, image: nil)
      return content if L::Schema.formatted?(content)

      { role: :user, content: content, _image: image }
    end

    def assistant(content)
      return content if L::Schema.formatted?(content)

      { role: :assistant, content: content }
    end

    # Structured Outputs is a feature that ensures the model will always generate responses
    # that adhere to your supplied JSON Schema, so you don't need to worry about the model
    # omitting a required key, or hallucinating an invalid enum value. This is a set of
    # helper methods to help you define your JSON Schema easily.
    def to_a(object)
      {
        'type' => 'object',
        'properties' => {
          'items' => {
            'type' => 'array', 'items' => to_h(object)
          }
        },
        'required' => ['items'],
        'additionalProperties' => false
      }
    end

    def to_h(object)
      {
        'type' => 'object',
        "properties": object.inject({}) { |h, (k, v)| h.merge(k.to_s => { 'type' => v.to_s }) },
        "required": object.keys,
        "additionalProperties": false
      }
    end
  end
end
