require_relative 'lib/blueprint/version'

Gem::Specification.new do |spec|
  spec.name          = "blueprint"
  spec.version       = Blueprint::VERSION
  spec.authors       = ["Callum Booth"]
  spec.email         = ["hi@cbooth.dev"]

  spec.summary       = "Simple, language-agnostic, intent-agnostic task sequencing."
  spec.description   = "Blueprint is a task sequencer. You describe the individual steps of your task in YAML and Blueprint runs them, in sequence or individually depending on what you need. Think `npm run ...`, but in Ruby... and for anything..."
  spec.homepage      = "https://cbooth.dev/blueprint"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cbooth/blueprint"
  spec.metadata["changelog_uri"] = "https://github.com/cbooth/blueprint/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "kwalify"
  spec.add_dependency "pastel"
  spec.add_dependency "tty"
  spec.add_dependency "tty-command"
  spec.add_dependency "tty-exit"
  spec.add_dependency "tty-logger"
  spec.add_dependency "tty-markdown"
  spec.add_dependency "tty-option"
  spec.add_dependency "tty-progressbar"
  spec.add_dependency "tty-spinner"
  
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
end
