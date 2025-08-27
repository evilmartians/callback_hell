# frozen_string_literal: true

module CallbackHell
  module Reports
    module Validations
      class Table < TableBase
        private

        def report_title
          "Callback Hell validations report"
        end

        def format_group_name(callback)
          callback.validation_type
        end
      end
    end
  end
end
