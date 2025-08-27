# frozen_string_literal: true

module CallbackHell
  module Reports
    class LineBase < Base
      def generate
        output = [report_title]

        @stats.by_model.each do |model_name, model_callbacks|
          output << "\n#{model_name}:"
          model_callbacks.sort_by(&:kind).each do |callback|
            output << format_callback(callback)
          end
        end

        output.join("\n")
      end

      private

      def report_title
        raise NotImplementedError
      end

      def format_callback(callback)
        [
          "  #{format_callback_name(callback)}",
          "method_name: #{callback.human_method_name}",
          "origin: #{callback.origin}",
          "association_generated: #{callback.association_generated ? "yes" : "no"}",
          "attribute_generated: #{callback.attribute_generated ? "yes" : "no"}",
          "inherited: #{callback.inherited ? "inherited" : "own"}",
          "conditional: #{callback.conditional ? "yes" : "no"}"
        ].compact.join(", ")
      end

      def format_callback_name(callback)
        raise NotImplementedError
      end
    end
  end
end
