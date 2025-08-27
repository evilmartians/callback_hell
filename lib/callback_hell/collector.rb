# frozen_string_literal: true

require "set"

module CallbackHell
  class Collector
    attr_reader :models

    def initialize(models = nil, paths: nil, kind: :callbacks, mode: :default)
      @paths = paths
      @kind = kind
      @mode = mode

      eager_load!
      @models = Set.new(models ? [*models] : ApplicationRecord.descendants)
    end

    def collect(select_models = models)
      select_models.flat_map { |model| collect_for_model(model) }
    end

    private

    def eager_load!
      Rails.application.eager_load!
      load_additional_paths
    end

    def collect_for_model(model)
      model.ancestors.select { |ancestor| ancestor < ActiveRecord::Base }
        # collect from parent to child to correctly handle inheritance
        .reverse
        .flat_map { |ancestor| collect_callbacks_for_class(model, ancestor) }
        .group_by(&:fingerprint)
        # merge groups
        .transform_values do |callbacks|
          probe = callbacks.first
          if probe.fingerprint.start_with?("1")
            # we must keep the last non-matching callback (i.e., if all callbacks are the same,
            # we must keep the first one)
            callbacks.each do |clbk|
              if clbk.callback != probe.callback
                probe = clbk
              end
            end
          end
          probe
        end
        .values
    end

    def collect_callbacks_for_class(model, klass)
      callbacks = klass.__callbacks
      callbacks = callbacks.slice(:validate) if @kind == :validations

      callbacks.flat_map do |kind, chain|
        chain.map { |callback| build_callback(model, callback, kind, klass) }
      end.then do |collected|
        next collected if @mode == :full

        collected.reject do |c|
          c.association_generated || c.attribute_generated || (
            @kind != :validations && c.callback_group == "validate"
          )
        end
      end
    end

    def build_callback(model, callback, kind, klass)
      Callback.new(
        model: model,
        rails_callback: callback,
        name: kind,
        defining_class: klass
      )
    end

    def load_additional_paths
      model_paths.each do |path|
        Dir[File.join(path, "**", "*.rb")].sort.each { |file| require_dependency file }
      end
    end

    def model_paths
      @model_paths ||= begin
        paths = engine_paths
        paths += [@paths] if @paths
        paths.select(&:exist?)
      end
    end

    def engine_paths
      @engine_paths ||= Rails::Engine.subclasses.map { |engine| engine.root.join("app/models") }
    end
  end
end
