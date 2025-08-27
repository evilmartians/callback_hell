# frozen_string_literal: true

RSpec.describe CallbackHell::Callback do
  let(:base_class) do
    Class.new do
      def self.name
        "TestModel"
      end

      def callback_method
      end
    end
  end

  let(:method) { base_class.instance_method(:callback_method) }

  describe "callback origin" do
    before do
      allow(method).to receive(:owner).and_return(base_class)
      allow(base_class).to receive(:instance_method).with(:callback_method).and_return(method)
    end

    it "detects Rails callbacks" do
      allow(method).to receive(:source_location)
        .and_return([Gem.loaded_specs["activerecord"].full_gem_path + "/lib/active_record.rb"])

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: :callback_method, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.origin).to eq(:rails)
    end

    it "detects gem callbacks" do
      allow(method).to receive(:source_location).and_return(["gems/devise/lib/devise.rb"])

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: :callback_method, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.origin).to eq(:gems)
    end

    it "detects own callbacks" do
      allow(method).to receive(:source_location).and_return([Rails.root.join("app/models/test.rb").to_s])

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: :callback_method, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.origin).to eq(:own)
    end
  end

  describe "validation types" do
    subject(:callback) do
      described_class.new(
        model: base_class,
        rails_callback: double(
          "Callback",
          kind: :before,
          filter: method_name,
          instance_variable_get: nil
        ),
        name: :validate,
        defining_class: base_class
      )
    end

    {
      validates_presence_of: "presence",
      validate_presence: "presence",
      validates_uniqueness_of: "uniqueness",
      validate_uniqueness: "uniqueness",
      validates_format_of: "format",
      validate_format: "format",
      validates_length_of: "length",
      validate_length: "length",
      validates_inclusion_of: "inclusion",
      validate_inclusion: "inclusion",
      validates_exclusion_of: "exclusion",
      validate_exclusion: "exclusion",
      validates_numericality_of: "numericality",
      validate_numericality: "numericality",
      validates_acceptance_of: "acceptance",
      validate_acceptance: "acceptance",
      validates_confirmation_of: "confirmation",
      validate_confirmation: "confirmation",
      validate_associated_records_for_comments: "associated",
      validate_associated_records_for_attachments: "associated",
      validate_publish_date_must_be_in_december: "custom",
      some_random_validation_method: "custom"
    }.each do |method, expected_type|
      context "with #{method}" do
        let(:method_name) { method }

        it "returns #{expected_type}" do
          expect(callback.validation_type).to eq(expected_type)
        end
      end
    end

    context "with non-standard validations" do
      let(:method_name) { proc { true } }

      it "returns custom for procs" do
        expect(callback.validation_type).to eq("custom")
      end
    end
  end

  describe "with humanized method names" do
    it "formats proc callbacks with location" do
      source_file = "active_record/associations/builder/belongs_to.rb"
      proc = proc { true }
      allow(proc).to receive(:source_location).and_return([source_file, 30])

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: proc, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.human_method_name).to eq("Proc (builder/belongs_to.rb:30)")
    end

    it "handles procs without source location" do
      proc = proc { true }
      allow(proc).to receive(:source_location).and_return(nil)

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: proc, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.human_method_name).to eq("Proc (unknown location)")
    end

    it "formats validator callbacks with attributes" do
      validator = ActiveRecord::Validations::PresenceValidator.new(attributes: [:name, :email])
      allow(base_class).to receive(:reflect_on_association).and_return(nil)

      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: validator, instance_variable_get: nil),
        name: :validation,
        defining_class: base_class
      )

      expect(callback.human_method_name).to eq("PresenceValidator (name, email)")
    end

    it "returns method name for symbol callbacks" do
      callback = described_class.new(
        model: base_class,
        rails_callback: double("Callback", kind: :before, filter: :my_callback, instance_variable_get: nil),
        name: :save,
        defining_class: base_class
      )

      expect(callback.human_method_name).to eq("my_callback")
    end
  end
end
