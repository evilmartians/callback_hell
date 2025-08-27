# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Callbacks::Line do
  include_context "test callbacks"
  subject(:report) { described_class.new(callbacks) }
  subject(:output) { report.generate }

  it "includes report header" do
    expect(output).to include("Callback Hell callbacks report:")
  end

  it "shows model name" do
    expect(output).to include("TestModel:")
  end

  it "shows callback details" do
    expect(output).to include("before_save")
    expect(output).to include("after_save")
    expect(output).to include("method_name: regular_callback")
    expect(output).to include("origin: own")
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

  it "formats each callback on a new line" do
    lines = output.split("\n")
    callback_lines = lines.select { |l| l.start_with?("  ") }
    expect(callback_lines.size).to eq(4)
  end
end
