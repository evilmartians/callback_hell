# frozen_string_literal: true

begin
  require "debug" unless ENV["CI"] == "true"
rescue LoadError
end

ENV["RAILS_ENV"] = "test"

require "bundler"
require "combustion"

require "callback_hell"

begin
  Bundler.require :default, :development

  # See https://github.com/pat/combustion
  Combustion.initialize!(:active_record, :active_model) do
    config.logger = Logger.new(nil)
    config.log_level = :fatal
  end
rescue => e
  # Fail fast if application couldn't be loaded
  $stdout.puts "Failed to load the app: #{e.message}\n#{e.backtrace.take(5).join("\n")}"
  exit(1)
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

require "rspec/rails"

# Stub IO console for table_tennis if it's not available
# https://github.com/gurgeous/table_tennis/blob/c26968ce003cf766afa9e8511f9e040d5071d519/test/test_helper.rb#L90
# rubocop:disable Layout/EmptyLineBetweenDefs
class FakeConsole
  def fileno = 123
  def getbyte = fakeread.shift
  def raw = yield
  def syswrite(str) = fakewrite << str
  def winsize = [2400, 800]
  def fakeread = (@fakeread ||= [])
  def fakewrite = (@fakewrite ||= StringIO.new)
end
# rubocop:enable Layout/EmptyLineBetweenDefs

if IO.console.nil?
  IO.define_singleton_method(:console) { FakeConsole.new }
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed

  config.after(:each) do
    ENV.delete("format")
    ENV.delete("model")
    ENV.delete("path")
    ENV.delete("sort")
    ENV.delete("mode")
  end
end
