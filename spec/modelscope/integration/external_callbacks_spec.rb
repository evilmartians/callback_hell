# frozen_string_literal: true

RSpec.describe CallbackHell, "with external ('gem') callbacks and validations" do
  subject(:bar) { CallbackHell::Collector.new(Bar, mode: :full).collect }

  it "has callbacks" do
    expect(bar).to have_callback(
      callback_name: :after_commit, method_name: :save_tags,
      origin: :gems, inherited: false
    )
  end

  it "has validations" do
    expect(bar).to have_validation(
      type: :custom, method_name: :validate_tags,
      origin: :gems, inherited: false
    )
  end
end
