# frozen_string_literal: true

module CallbackHell
  module Reports
    module Callbacks
      class Github < GithubBase
        private

        def report_title
          "Callback Hell callbacks report"
        end

        def format_group_name(callback)
          "#{timing_symbol(callback.kind)}/#{callback.callback_group}"
        end

        def timing_symbol(timing)
          case timing
          when :before, "before" then "⇥"
          when :after, "after" then "↦"
          when :around, "around" then "↔"
          else
            "  "
          end
        end
      end
    end
  end
end
