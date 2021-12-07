# frozen_string_literal: true

require 'blueprint'
require 'spec_helper'

RSpec.describe Blueprint do
    context 'integration tests' do
        it 'loads a functional task spec, and checks that the output exists' do
            bp = Blueprint::Blueprint.new 
            bp.go(["#{RSPEC_ROOT}/resources/integration.blueprint"],
                {
                    from: nil,
                    to: nil,
                    tasks: nil
                }
            )

            generated_file = "#{RSPEC_ROOT}/resources/tmp/touchfile"

            expect(File.exist? generated_file).to be true
            File.delete(generated_file) if File.exist? generated_file
        end
    end
end
