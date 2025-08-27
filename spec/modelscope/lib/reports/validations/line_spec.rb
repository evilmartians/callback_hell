# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Validations::Line do
  include_context "test validation callbacks"
  subject(:report) { described_class.new(validation_callbacks) }
  subject(:output) { report.generate }

  it "includes report header" do
    expect(output).to include("Callback Hell validations report:")
  end

  it "shows model name" do
    expect(output).to include("TestModel:")
  end

  it "shows validation types" do
    expect(output).to include("associated")
    expect(output).to include("custom")
  end

  it "indicates conditional status" do
    expect(output).to include("conditional: yes")
    expect(output).to include("conditional: no")
  end

  it "indicates inheritance status" do
    expect(output).to include("inherited: inherited")
    expect(output).to include("inherited: own")
  end

  it "indicates source types" do
    expect(output).to include("association_generated: yes")
    expect(output).to include("attribute_generated: yes")
  end

  it "formats each validation on a new line" do
    lines = output.split("\n")
    validation_lines = lines.select { |l| l.start_with?("  ") }
    expect(validation_lines.size).to eq(3)
  end
end
