# frozen_string_literal: true

RSpec.describe CallbackHell, "with inherited callbacks and validations" do
  subject(:bar) { CallbackHell.collect_callbacks(Bar) }
  subject(:bar_jr) { CallbackHell.collect_callbacks(BarJr) }

  specify do
    expect(bar_jr.size).to eq(bar.size)
  end

  it "has inherited callbacks and validations from a module" do
    expect(bar).to have_callback(
      callback_name: :after_commit,
      method_name: :be_annoying, inherited: false
    )
    expect(bar).not_to have_validation(
      type: :custom,
      method_name: :be_annoying, inherited: false
    )
  end

  it "has inherited callbacks and validations from a class" do
    expect(bar_jr).to have_callback(
      callback_name: :after_commit,
      method_name: :be_annoying, origin: :own, inherited: true
    )
    expect(bar_jr).not_to have_validation(
      type: :presence,
      human_method_name: /^Presence.*\(name\)/,
      origin: :own,
      inherited: true
    )

    expect(bar).to have_callback(
      callback_name: :after_commit,
      method_name: :noop, origin: :own, inherited: false
    )
    expect(bar_jr).to have_callback(
      callback_name: :after_commit,
      method_name: :noop, origin: :own, inherited: true
    )
  end

  context "with mode=full" do
    subject(:bar) { CallbackHell.collect_callbacks(Bar, mode: :full) }
    subject(:bar_jr) { CallbackHell.collect_callbacks(BarJr, mode: :full) }

    specify do
      expect(bar_jr.size).to eq(bar.size)
    end

    it "has inherited validation callbacks" do
      expect(bar).to have_validation(
        type: :custom,
        method_name: :be_annoying, inherited: false
      )
      expect(bar_jr).to have_validation(
        type: :presence,
        human_method_name: /^Presence.*\(name\)/,
        origin: :own,
        inherited: true
      )
    end
  end
end
