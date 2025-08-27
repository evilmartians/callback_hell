# frozen_string_literal: true

module CallbackHell
  module Reports
    class Base
      attr_reader :callbacks, :stats

      def initialize(callbacks, **opts)
        @callbacks = callbacks
        @stats = Stats.new(callbacks, **opts)
      end

      def generate
        raise NotImplementedError
      end
    end
  end
end
