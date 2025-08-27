# frozen_string_literal: true

module CallbackHell
  module Reports
    module Callbacks
      class Line < LineBase
        private

        def report_title
          "Callback Hell callbacks report:"
        end

        def format_callback_name(callback)
          "#{callback.kind}_#{callback.callback_group}"
        end
      end
    end
  end
end
