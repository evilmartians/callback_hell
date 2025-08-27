# frozen_string_literal: true

require "table_tennis"

module CallbackHell
  module Reports
    class TableBase < Base
      def generate
        headers = ["Model", "Kind", "Total", "Own", "Inherited"]
        headers << "Rails" if stats.rails?
        headers << "Associations" if stats.associations?
        headers << "Attributes" if stats.attributes?
        headers.concat(["Gems", "Conditional"])

        headers_mapping = headers.index_by { |h| h.parameterize.to_sym }

        table = TableTennis.new(generate_rows(headers_mapping.keys)) do |t|
          t.title = report_title
          t.headers = headers_mapping
          t.placeholder = ""
          t.color_scales = {total: :gr}

          # Don't shrink table if we run in a test environment,
          # we need full labels and values to test
          t.layout = false if defined?(Rails) && Rails.env.test?
        end

        table.to_s
      end

      private

      def report_title
        raise NotImplementedError
      end

      def generate_rows(headers)
        rows = []
        @stats.by_model.each_with_index do |(model_name, _), index|
          # TODO: not supported by table_tennis
          # rows << :separator if index > 0
          rows.concat(model_rows(model_name))
        end
        rows.map { headers.zip(_1).to_h }
      end

      def model_rows(model_name)
        rows = []
        total_stats = @stats.stats_for(model_name)

        # Add total row
        rows << [
          model_name,
          "all",
          total_stats[:total],
          total_stats[:own],
          total_stats[:inherited],
          stats.rails? ? total_stats[:rails] : nil,
          stats.associations? ? total_stats[:association_generated] : nil,
          stats.attributes? ? total_stats[:attribute_generated] : nil,
          total_stats[:gems],
          total_stats[:conditional]
        ].compact

        # Group and sort callbacks
        grouped_callbacks = @stats.by_model[model_name].group_by { |cb| format_group_name(cb) }

        grouped_callbacks.keys.sort.each do |group_name|
          group_callbacks = grouped_callbacks[group_name]
          rows << [
            "",
            group_name,
            group_callbacks.size,
            group_callbacks.count { |cb| cb.origin == :own },
            group_callbacks.count(&:inherited),
            stats.rails? ? group_callbacks.count { |cb| cb.origin == :rails } : nil,
            stats.associations? ? group_callbacks.count(&:association_generated) : nil,
            stats.attributes? ? group_callbacks.count(&:attribute_generated) : nil,
            group_callbacks.count { |cb| cb.origin == :gems },
            group_callbacks.count(&:conditional)
          ].compact
        end

        rows
      end

      def format_group_name(callback)
        raise NotImplementedError
      end
    end
  end
end
