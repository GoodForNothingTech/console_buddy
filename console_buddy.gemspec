
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "console_buddy/version"

Gem::Specification.new do |spec|
  spec.name          = "console_buddy"
  spec.version       = ConsoleBuddy::VERSION
  spec.authors       = ["Micah Bowie", "Good For Nothing"]
  spec.email         = ["micahbowie20@gmail.com", "micah@goodfornothing.tech"]

  spec.summary       = "Have you ever had debugging tricks, aliases, or shortcuts that don't make sense as application code but, are super helpful in the console? Define custom methods, helper, and aliases for your app and use them in your rails console or IRB session."
  spec.description   = 'Define custom methods, helper, and aliases for your app and use them in your rails console or IRB session.'

  spec.files = Dir['lib/**/*'] + Dir['spec/**/*']

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/GoodForNothingTech/console_buddy/issues",
    "changelog_uri"     => "https://github.com/GoodForNothingTech/console_buddy/CHANGELOG.md",
    "documentation_uri" => "https://github.com/GoodForNothingTech/console_buddy",
    "source_code_uri"   => "https://github.com/GoodForNothingTech/console_buddy",
  }

  spec.required_ruby_version = ">= 2.0"
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails'
  spec.add_dependency 'table_print'
  spec.add_dependency 'httparty'
  spec.add_dependency 'progress_bar'
  spec.add_dependency 'terminal-table'

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "activejob"
  spec.add_development_dependency "resque"
  spec.add_development_dependency "webmock"
end
