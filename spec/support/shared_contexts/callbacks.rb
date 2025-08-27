# frozen_string_literal: true

RSpec.shared_context "test callbacks" do
  let(:model_class) {
    Class.new(ApplicationRecord) {
      def self.name
        "TestModel"
      end
    }
  }

  let(:callbacks) do
    [
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: :regular_callback,
          instance_variable_get: nil
        ),
        name: "save",
        defining_class: model_class
      ),
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :after,
          filter: :conditional_callback,
          instance_variable_get: ->(var) { (var == :@if) ? [:condition] : nil }
        ),
        name: "save",
        defining_class: model_class
      ),
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: ActiveRecord::Validations::PresenceValidator.new(attributes: [:parent]),
          instance_variable_get: nil
        ),
        name: "validation",
        defining_class: model_class
      ).tap { |cb|
        allow(cb).to receive(:origin).and_return(:rails)
        allow(cb).to receive(:association_generated).and_return(true)
        allow(cb).to receive(:attribute_generated).and_return(true) # Added this
        allow(cb).to receive(:inherited).and_return(true)
      },
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :after,
          filter: :gem_callback,
          instance_variable_get: ->(var) { (var == :@if) ? [:condition] : nil }
        ),
        name: "commit",
        defining_class: Class.new {
          def self.name
            "GemModule"
          end
        }
      ).tap { |cb|
        allow(cb).to receive(:inherited).and_return(true)
      }
    ]
  end
end
