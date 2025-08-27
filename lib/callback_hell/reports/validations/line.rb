# frozen_string_literal: true

module CallbackHell
  module Reports
    module Validations
      class Line < LineBase
        private

        def report_title
          "Callback Hell validations report:"
        end

        def format_callback_name(callback)
          if callback.method_name.is_a?(Symbol) || callback.method_name.is_a?(String)
            type = callback.validation_type
            (type == "custom") ? "custom (#{callback.method_name})" : type
          else
            callback.validation_type
          end
        end
      end
    end
  end
end
