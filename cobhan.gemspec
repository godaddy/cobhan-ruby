# frozen_string_literal: true

require_relative 'lib/cobhan/version'

Gem::Specification.new do |spec|
  spec.name = 'cobhan'
  spec.version = Cobhan::VERSION
  spec.authors = ['GoDaddy']
  spec.email = ['oss@godaddy.com']

  spec.summary = 'Ruby wrapper library for the Cobhan FFI system'
  spec.description = <<~DESCRIPTION
    Cobhan FFI is a proof of concept system for enabling shared code to be written
    in Rust or Go and consumed from all major languages/platforms in a safe and effective way,
    using easy helper functions to manage any unsafe data marshaling.
  DESCRIPTION

  spec.homepage = 'https://github.com/godaddy/cobhan-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/godaddy/cobhan-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/godaddy/cobhan-ruby/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|demo|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '~> 1.15.4'

  spec.add_development_dependency 'rspec', '~> 3.10.0'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'simplecov-console', '~> 0.9.1'
end
