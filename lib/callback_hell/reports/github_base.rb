# frozen_string_literal: true

module CallbackHell
  module Reports
    class GithubBase < Base
      def generate
        output = ["::group::#{report_title}"]

        @stats.by_model.each_with_index do |(model_name, _), index|
          output << "" if index > 0
          output << "::group::#{model_name}"

          # Add total row first
          total_stats = @stats.stats_for(model_name)
          output << format_group(
            "all",
            total_stats[:total],
            total_stats[:own],
            total_stats[:inherited],
            total_stats[:rails],
            total_stats[:association_generated],
            total_stats[:attribute_generated],
            total_stats[:gems],
            total_stats[:conditional]
          )

          # Group and sort callbacks
          grouped_callbacks = @stats.by_model[model_name].group_by { |cb| format_group_name(cb) }

          grouped_callbacks.keys.sort.each do |group_name|
            group_callbacks = grouped_callbacks[group_name]
            output << format_group(
              group_name,
              group_callbacks.size,
              group_callbacks.count { |cb| cb.origin == :own },
              group_callbacks.count(&:inherited),
              group_callbacks.count { |cb| cb.origin == :rails },
              group_callbacks.count(&:association_generated),
              group_callbacks.count(&:attribute_generated),
              group_callbacks.count { |cb| cb.origin == :gems },
              group_callbacks.count(&:conditional)
            )
          end

          output << "::endgroup::"
        end

        output << "::endgroup::"
        output.join("\n")
      end

      private

      def report_title
        raise NotImplementedError
      end

      def format_group(name, total, own, inherited, rails, association_generated, attribute_generated, gems, conditional)
        "::debug::kind=#{name} total=#{total} own=#{own} inherited=#{inherited} rails=#{rails} association_generated=#{association_generated} attribute_generated=#{attribute_generated} gems=#{gems} conditional=#{conditional}"
      end

      def format_group_name(callback)
        raise NotImplementedError
      end
    end
  end
end
