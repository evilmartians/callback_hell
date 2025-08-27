# frozen_string_literal: true

RSpec.describe CallbackHell, "with an empty ActiveRecord" do
  let(:options) { {} }
  subject(:ar) { CallbackHell::Collector.new(ApplicationRecord, **options).collect }

  it "does not have any own or rails callbacks or validations" do
    expect(ar).not_to have_callback(origin: :rails)
    expect(ar).not_to have_callback(origin: :own)
    expect(ar).not_to have_validation(origin: :own)
  end

  context "with full mode" do
    let(:options) { {mode: :full} }

    it "does have callbacks on an empty ActiveRecord class" do
      expect(ar).to have_callback(
        method_name: :cant_modify_encrypted_attributes_when_frozen,
        origin: :rails, inherited: false
      )
      expect(ar).to have_callback(
        method_name: :normalize_changed_in_place_attributes,
        origin: :rails, inherited: false
      )
    end
  end
end
