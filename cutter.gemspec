# frozen_string_literal: true

require_relative "lib/cutter/version"

Gem::Specification.new do |spec|
  spec.name = "cutter"
  spec.version = Cutter::VERSION
  spec.authors = ["SolehMQ"]
  spec.email = ["solehudinmq@gmail.com"]

  spec.summary = "Cutter is a Ruby library that implements the circuit breaker design pattern, so your application will be more stable even if your 3rd party application is having problems."
  spec.description = "With the Cutter library, your Ruby application will remain stable even if a connected third-party application experiences problems. This library implements the circuit breaker design pattern; in other words, it protects your application from system failures caused by external factors."
  spec.homepage = "https://github.com/solehudinmq/cutter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "logger"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
