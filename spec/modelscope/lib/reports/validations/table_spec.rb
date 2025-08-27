# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Validations::Table do
  include_context "test validation callbacks"
  subject(:report) { described_class.new(validation_callbacks, mode: :full) }
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
    expect(output).to match(/\b3\b/) # total
    expect(output).to match(/\b3\b/) # own
    expect(output).to match(/\b1\b/) # inherited
    expect(output).to match(/\b1\b/) # association_generated
    expect(output).to match(/\b1\b/) # attribute_generated
  end

  it "groups validations by type" do
    lines = output.lines
    expect(lines).to include(match(/associated/))
    expect(lines).to include(match(/custom/))
  end
end
