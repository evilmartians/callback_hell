# frozen_string_literal: true

RSpec.describe CallbackHell::Reports::Callbacks::Github do
  include_context "test callbacks"
  subject(:report) { described_class.new(callbacks) }
  subject(:output) { report.generate }

  it "shows model totals" do
    total_line = output.lines.find { |l| l.include?("kind=all") }
    expect(total_line).to match(/total=4/)
    expect(total_line).to match(/own=2/)
    expect(total_line).to match(/inherited=2/)
    expect(total_line).to match(/conditional=2/)
    expect(total_line).to match(/association_generated=1/)
    expect(total_line).to match(/attribute_generated=1/)
  end

  it "groups callbacks correctly" do
    groups = output.lines.select { |l| l.include?("::debug::") }

    expect(groups.size).to eq(5) # "all" and four groups

    before_save_group = groups.find { |l| l.include?("kind=⇥/save") }
    after_save_group = groups.find { |l| l.include?("kind=↦/save") }
    validation_group = groups.find { |l| l.include?("kind=⇥/validation") }
    commit_group = groups.find { |l| l.include?("kind=↦/commit") }

    expect(before_save_group).to match(/total=1/)
    expect(before_save_group).to match(/own=1/)
    expect(before_save_group).to match(/conditional=0/)

    expect(after_save_group).to match(/total=1/)
    expect(after_save_group).to match(/own=1/)
    expect(after_save_group).to match(/conditional=1/)

    expect(validation_group).to match(/total=1/)
    expect(validation_group).to match(/rails=1/)

    expect(commit_group).to match(/total=1/)
    expect(commit_group).to match(/gems=1/)
    expect(commit_group).to match(/inherited=1/)
    expect(commit_group).to match(/conditional=1/)
  end
end
