# frozen_string_literal: true

require_relative "lib/callback_hell/version"

Gem::Specification.new do |s|
  s.name = "callback_hell"
  s.version = CallbackHell::VERSION
  s.authors = ["Yaroslav Markin", "Vladimir Dementyev"]
  s.email = ["yaroslav@markin.net", "dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/evilmartians/callback_hell"
  s.summary = "Analyze Rails models for callbacks and validations"
  s.description = "Callback Hell analyzes your Rails application models and provides useful insights on callbacks and validations defined"

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/evilmartians/callback_hell/issues",
    "changelog_uri" => "https://github.com/palkan/callback_hell/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/evilmartians/callback_hell",
    "homepage_uri" => "http://github.com/evilmartians/callback_hell",
    "source_code_uri" => "http://github.com/evilmartians/callback_hell"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md file_id.diz]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.0"

  s.add_dependency "rails", ">= 7.0"

  s.add_dependency "zeitwerk"
  s.add_dependency "table_tennis"

  s.add_development_dependency "bundler", ">= 2.4"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "combustion", ">= 1.5"
  s.add_development_dependency "sqlite3", ">= 1.5"
  s.add_development_dependency "rspec-rails", ">= 6.0"
end
