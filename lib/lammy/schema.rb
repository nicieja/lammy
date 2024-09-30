# frozen_string_literal: true

module L
  # Structured Outputs is a feature that ensures the model will always generate responses
  # that adhere to your supplied JSON Schema, so you don't need to worry about the model
  # omitting a required key, or hallucinating an invalid enum value. This is a set of
  # helper methods to help you define your JSON Schema easily.
  module Schema
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
        "properties": object.inject({}) { |h, (k, v)| h.merge(k => { 'type' => v }) },
        "required": object.keys,
        "additionalProperties": false
      }
    end
  end
end
