# frozen_string_literal: true

require 'kwalify/meta-validator'

require 'blueprint/helpers'

RSpec.describe Blueprint do
  context 'schema' do
    it 'is a valid Kwalify schema' do
      meta_validator = Kwalify::MetaValidator.instance
      schema = YAML.load_file("#{File.dirname __FILE__}/../data/schema.yaml")
      errors = meta_validator.validate(schema)
      expect(errors).to be_empty
    end
  end
end
