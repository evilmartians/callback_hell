# frozen_string_literal: true

RSpec.describe CallbackHell::Stats do
  let(:model_class) { Class.new }
  let(:callbacks) do
    [
      double(
        "Callback",
        model: model_class,
        origin: :own,
        inherited: false,
        conditional: true,
        callback_group: "save",
        association_generated: false,
        attribute_generated: true
      ),
      double(
        "Callback",
        model: model_class,
        origin: :rails,
        inherited: false,
        conditional: false,
        callback_group: "validation",
        association_generated: true,
        attribute_generated: false
      )
    ]
  end

  before do
    allow(model_class).to receive(:name).and_return("TestModel")
  end

  describe "#by_model" do
    let(:another_model_class) { Class.new }
    before do
      allow(another_model_class).to receive(:name).and_return("AnotherModel")
    end

    let(:all_callbacks) do
      [*callbacks, double(
        "Callback",
        model: another_model_class,
        origin: :rails,
        inherited: false,
        conditional: false,
        callback_group: "validation",
        association_generated: true,
        attribute_generated: false
      )]
    end

    it "groups callbacks by model name" do
      stats = described_class.new(all_callbacks)
      expect(stats.by_model["TestModel"]).to eq(callbacks)
    end

    context "with sort_by=size&sort_order=desc" do
      it "sorts callbacks by size in descending order" do
        stats = described_class.new(all_callbacks, sort_by: :size, sort_order: :desc).by_model
        expect(stats.first.first).to eq("TestModel")
      end
    end

    context "with sort_by=size&sort_order=asc" do
      it "sorts callbacks by size in descending order" do
        stats = described_class.new(all_callbacks, sort_by: :size, sort_order: :asc).by_model
        expect(stats.first.first).to eq("AnotherModel")
      end
    end

    context "with sort_by=name&sort_order=asc" do
      it "sorts callbacks by size in descending order" do
        stats = described_class.new(all_callbacks, sort_by: :name, sort_order: :asc).by_model
        expect(stats.first.first).to eq("AnotherModel")
      end
    end
  end

  describe "#stats_for" do
    subject(:stats) { described_class.new(callbacks).stats_for("TestModel") }

    it "counts callbacks by their properties" do
      expect(stats[:total]).to eq(2)
      expect(stats[:own]).to eq(1)
      expect(stats[:conditional]).to eq(1)
      expect(stats[:association_generated]).to eq(1)
      expect(stats[:attribute_generated]).to eq(1)
    end

    it "returns empty hash for unknown model" do
      expect(described_class.new(callbacks).stats_for("Unknown")).to eq({})
    end
  end

  describe "#stats_for_group" do
    it "returns stats for specific callback group" do
      stats = described_class.new(callbacks).stats_for_group("TestModel", "save")
      expect(stats[:total]).to eq(1)
      expect(stats[:attribute_generated]).to eq(1)
      expect(stats[:association_generated]).to eq(0)
    end

    it "returns zero counts for unknown group" do
      stats = described_class.new(callbacks).stats_for_group("TestModel", "unknown")
      expect(stats[:total]).to eq(0)
    end
  end
end
