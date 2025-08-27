# frozen_string_literal: true

require "zeitwerk"

module CallbackHell
  class Error < StandardError; end

  def self.loader # @private
    @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
      loader.ignore("#{__dir__}/tasks")
      loader.setup
    end
  end

  def self.collect_callbacks(*models, **options)
    collector = Collector.new(**options)
    collector.collect(models)
  end

  def self.collect_validations(*models, **options)
    collector = Collector.new(**options, kind: :validations)
    collector.collect(models)
  end
end

CallbackHell.loader

require "callback_hell/railtie" if defined?(Rails::Railtie)
