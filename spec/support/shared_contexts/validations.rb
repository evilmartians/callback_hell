# frozen_string_literal: true

RSpec.shared_context "test validation callbacks" do
  let(:model_class) {
    Class.new(ApplicationRecord) {
      def self.name
        "TestModel"
      end
    }
  }

  let(:validation_callbacks) do
    [
      # A presence validator
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: ActiveModel::Validations::PresenceValidator.new(attributes: [:name]),
          instance_variable_get: ->(var) { (var == :@if) ? [:condition] : nil }
        ),
        name: "validate",
        defining_class: model_class
      ).tap { |cb|
        allow(cb).to receive(:association_generated).and_return(true)
        allow(cb).to receive(:attribute_generated).and_return(true)
        allow(cb).to receive(:inherited).and_return(true)
      },
      # A custom validation method
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: :validate_publish_date_must_be_in_december,
          instance_variable_get: nil
        ),
        name: "validate",
        defining_class: model_class
      ),
      # An associated records validation
      CallbackHell::Callback.new(
        model: model_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: :validate_associated_records_for_comments,
          instance_variable_get: nil
        ),
        name: "validate",
        defining_class: model_class
      )
    ]
  end
end
