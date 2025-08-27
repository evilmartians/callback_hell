# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Validations::Github do
  include_context "test validation callbacks"
  subject(:report) { described_class.new(validation_callbacks) }
  subject(:output) { report.generate }

  it "shows model totals" do
    total_line = output.lines.find { |l| l.include?("kind=all") }
    expect(total_line).to match(/total=3/)
    expect(total_line).to match(/own=3/)
    expect(total_line).to match(/inherited=1/)
    expect(total_line).to match(/conditional=1/)
    expect(total_line).to match(/association_generated=1/)
    expect(total_line).to match(/attribute_generated=1/)
  end

  it "groups validations by type" do
    debug_lines = output.lines.select { |l| l.include?("::debug::") }
    types = debug_lines.map { |l| l[/kind=(\w+)/, 1] }

    expect(types).to include("associated")
    expect(types).to include("custom")
  end
end
