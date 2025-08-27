# frozen_string_literal: true

RSpec.describe CallbackHell::Collector do
  let(:test_model) { Class.new(ApplicationRecord) }

  before do
    stub_const("TestModel", test_model)
    allow(ApplicationRecord).to receive(:descendants).and_return([test_model])
  end

  describe "collecting" do
    it "returns array of Callback objects" do
      collector = described_class.new(test_model)
      expect(collector.collect).to all(be_a(CallbackHell::Callback))
    end

    it "accepts array of models" do
      test_model2 = Class.new(ApplicationRecord)
      stub_const("TestModel2", test_model2)

      collector = described_class.new([test_model, test_model2], mode: :full)
      models = collector.collect.map(&:model).uniq

      expect(models).to match_array([test_model, test_model2])
    end

    context "with validation kind" do
      it "filters only validation callbacks" do
        callbacks = double("Callbacks", slice: {validate: []})
        allow(test_model).to receive(:__callbacks).and_return(callbacks)

        collector = described_class.new(test_model, kind: :validations)
        collector.collect

        expect(callbacks).to have_received(:slice).with(:validate)
      end
    end

    context "with callbacks kind" do
      it "does not filter callbacks" do
        callbacks = double("Callbacks")
        allow(callbacks).to receive(:flat_map).and_return([])
        allow(callbacks).to receive(:slice) # add this
        allow(test_model).to receive(:__callbacks).and_return(callbacks)

        collector = described_class.new(test_model, kind: :callbacks)
        collector.collect

        expect(callbacks).not_to have_received(:slice)
      end
    end
  end

  describe "with models" do
    it "returns passed models as a set" do
      collector = described_class.new(test_model)
      expect(collector.models).to be_a(Set)
      expect(collector.models.first).to eq(test_model)
    end

    it "discovers application models when no models passed" do
      stub_const("TestModel", test_model)

      allow(ApplicationRecord).to receive(:descendants).and_return([test_model])
      allow(Rails.application).to receive(:eager_load!)

      collector = described_class.new
      expect(collector.models.to_a).to eq([test_model])
    end
  end

  describe "paths handling" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
    end

    it "accepts additional paths" do
      test_path = Rails.root.join("extra_models")
      collector = described_class.new(nil, paths: test_path)
      expect(collector.send(:model_paths)).to include(test_path)
    end

    it "includes Rails Engine paths" do
      engine_path = Rails.root.join("engine_path/app/models")
      engine = Class.new(Rails::Engine) do
        define_singleton_method(:root) { Rails.root.join("engine_path") }
      end

      allow(Rails::Engine).to receive(:subclasses).and_return([engine])

      collector = described_class.new
      expect(collector.send(:model_paths)).to include(engine_path)
    end
  end
end
