# frozen_string_literal: true

module CallbackHell
  class Stats
    COUNTERS = %i[
      total own inherited rails gems conditional
      association_generated attribute_generated
    ].freeze

    SORT = %i[size name].freeze
    SORT_ORDER = %i[desc asc].freeze

    MODE = %i[default full].freeze

    attr_reader :callbacks
    private attr_reader :sort_by, :sort_order

    def initialize(callbacks, sort_by: :size, sort_order: :desc, mode: :default, kind: :callbacks)
      @callbacks = callbacks
      @stats_cache = {}
      @sort_by = sort_by
      raise ArgumentError, "Invalid sort_by: #{@sort_by}. Available: #{SORT.join(", ")}" unless SORT.include?(@sort_by)
      @sort_order = sort_order
      raise ArgumentError, "Invalid sort_order: #{@sort_order}. Available: #{SORT_ORDER.join(", ")}" unless SORT_ORDER.include?(@sort_order)
      @mode = mode
      raise ArgumentError, "Invalid mode: #{@mode}. Available: #{MODE.join(", ")}" unless MODE.include?(@mode)
      @kind = kind
    end

    def by_model
      @by_model ||= callbacks.group_by { |cb| cb.model.name }.sort_by do |name, callbacks|
        if sort_by == :size
          callbacks.size
        elsif sort_by == :name
          name
        end
      end.tap do |sorted|
        sorted.reverse! if sort_order == :desc
      end.to_h
    end

    def stats_for(model_name)
      @stats_cache[model_name] ||= begin
        model_callbacks = by_model[model_name]
        return {} unless model_callbacks

        collect_stats(model_callbacks)
      end
    end

    def stats_for_group(model_name, group)
      key = "#{model_name}_#{group}"
      @stats_cache[key] ||= begin
        model_callbacks = by_model[model_name]&.select { |cb| cb.callback_group == group }
        return {} unless model_callbacks

        collect_stats(model_callbacks)
      end
    end

    def rails?
      @mode == :full || @kind == :validations
    end

    def associations?
      @mode == :full
    end

    def attributes?
      @mode == :full
    end

    private

    def collect_stats(callbacks)
      callbacks.each_with_object(initial_stats) do |cb, stats|
        stats[:total] += 1
        stats[:own] += 1 if cb.origin == :own
        stats[:inherited] += 1 if cb.inherited
        stats[:rails] += 1 if cb.origin == :rails
        stats[:gems] += 1 if cb.origin == :gems
        stats[:conditional] += 1 if cb.conditional
        stats[:association_generated] += 1 if cb.association_generated
        stats[:attribute_generated] += 1 if cb.attribute_generated
      end
    end

    def initial_stats
      COUNTERS.to_h { |counter| [counter, 0] }
    end
  end
end
