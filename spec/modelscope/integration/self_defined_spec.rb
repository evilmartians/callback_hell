# frozen_string_literal: true

RSpec.describe CallbackHell, "with user-defined callbacks and validations" do
  subject(:foo) { CallbackHell::Collector.new(Foo, mode: :full).collect }
  subject(:bar) { CallbackHell::Collector.new(Bar, kind: :validations, mode: :full).collect }

  it "does have manually added callbacks" do
    expect(foo).to have_callback(
      callback_name: :before_validation,
      method_name: :noop, origin: :own
    )
    expect(foo).to have_callback(
      callback_name: :after_validation,
      method_name: :noop, origin: :own
    )
    expect(foo).to have_callback(
      callback_name: :before_create,
      method_name: :noop, origin: :own
    )
    expect(foo).to have_callback(
      callback_name: :after_create,
      method_name: :noop, origin: :own
    )
  end

  it "does have manually added callbacks with detected conditions" do
    expect(foo).to have_callback(
      callback_name: :around_create,
      method_name: :noop, origin: :own, conditional: true
    )
  end

  it "does have manually added validations" do
    expect(foo).to have_validation(
      type: :presence, human_method_name: /\(name\)/, origin: :own
    )
    expect(foo).to have_validation(
      type: :uniqueness, human_method_name: /\(name\)/, origin: :own
    )
    expect(bar).to have_validation(
      type: :presence,
      human_method_name: /\(name\)/, origin: :own
    )
  end

  it "does have manually added validations with detected conditions" do
    expect(foo).to have_validation(
      type: :presence,
      human_method_name: /\(title\)/,
      origin: :own,
      conditional: true
    )
  end
end
