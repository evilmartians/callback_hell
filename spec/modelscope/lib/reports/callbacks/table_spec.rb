# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Callbacks::Table do
  include_context "test callbacks"
  subject(:report) { described_class.new(callbacks, mode: :full) }
  subject(:output) { report.generate }

  it "includes all columns" do
    expect(output).to include("Model")
    expect(output).to include("Kind")
    expect(output).to include("Total")
    expect(output).to include("Own")
    expect(output).to include("Inherited")
    expect(output).to include("Rails")
    expect(output).to include("Associations")
    expect(output).to include("Attributes")
    expect(output).to include("Gems")
    expect(output).to include("Conditional")
  end

  it "shows totals for model" do
    expect(output).to include("TestModel")
    expect(output).to include("all")
    expect(output).to match(/\b4\b/) # total
    expect(output).to match(/\b2\b/) # own
    expect(output).to match(/\b1\b/) # inherited
    expect(output).to match(/\b1\b/) # association_generated
    expect(output).to match(/\b1\b/) # attribute_generated
  end

  it "groups callbacks by type" do
    expect(output).to include("⇥")  # before
    expect(output).to include("↦")  # after
    expect(output).to include("save")
    expect(output).to include("validation")
    expect(output).to include("commit")
  end

  context "with mode=default" do
    subject(:report) { described_class.new(callbacks, mode: :default) }

    it "doesn't include associations and attributes" do
      expect(output).to include("Model")
      expect(output).to include("Kind")
      expect(output).to include("Total")
      expect(output).to include("Own")
      expect(output).to include("Inherited")
      expect(output).not_to include("Rails")
      expect(output).not_to include("Associations")
      expect(output).not_to include("Attributes")
      expect(output).to include("Gems")
      expect(output).to include("Conditional")
    end
  end
end
