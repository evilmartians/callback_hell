# frozen_string_literal: true

module CallbackHell
  class Runner
    DEFAULT_FORMAT = :table

    def self.run(format: DEFAULT_FORMAT, model: nil, paths: nil, kind: :callbacks, **opts)
      new(format: format, model: model, paths: paths, kind: kind, **opts).run
    end

    def initialize(format:, model:, paths:, kind: :callbacks, sort_by: :size, sort_order: :desc, mode: :default)
      @format = (format || DEFAULT_FORMAT).to_sym
      @model_name = model
      @paths = paths
      @kind = kind
      @sort_by = sort_by
      @sort_order = sort_order
      @mode = mode
    end

    def run
      if @kind == :report
        [:callbacks, :validations].map do |ckind|
          generate_report(collect_callbacks(ckind), ckind)
        end.join("\n\n")
      else
        generate_report(collect_callbacks(@kind), @kind)
      end
    end

    private

    def collect_callbacks(ckind)
      Collector.new(find_model_class, paths: @paths, kind: ckind, mode: @mode).collect
    end

    def generate_report(callbacks, ckind)
      find_reporter_class(ckind).new(
        callbacks, sort_by: @sort_by, sort_order: @sort_order,
        mode: @mode, kind: ckind
      ).generate
    end

    def find_reporter_class(ckind)
      namespace = ckind.to_s.capitalize
      format = @format.to_s.capitalize
      class_name = "CallbackHell::Reports::#{namespace}::#{format}"
      class_name.constantize
    rescue NameError
      raise CallbackHell::Error, "Unknown format: #{@format} for #{ckind}"
    end

    def find_model_class
      return unless @model_name

      if @model_name.match?(/^[A-Z]/)
        @model_name.constantize
      else
        @model_name.classify.constantize
      end
    rescue NameError
      raise CallbackHell::Error, "Cannot find model: #{@model_name}"
    end
  end
end
