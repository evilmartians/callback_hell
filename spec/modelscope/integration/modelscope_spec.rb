# frozen_string_literal: true

RSpec.describe CallbackHell do
  context "with reporting" do
    it "supports different formats" do
      line = callback_hell("Foo", format: :line)
      expect(line).to include("after_validation")
      expect(line).to include("after_create")

      table = callback_hell("Foo", format: :table)
      expect(table).to_not include("after_create")
      expect(table).to include("all")
      expect(table).to include("/create")
    end
  end

  context "with model filtering" do
    it "can handle both file name and model name as a parameter" do
      expect(callback_hell("foo")).to eq(callback_hell("Foo"))
    end

    it "can load models both by file/name and Constant::Name" do
      expect(callback_hell("bar/baz")).to eq(callback_hell("Bar::Baz"))
    end
  end

  def callback_hell(model, format: :line)
    CallbackHell::Runner.run(model: model, format: format)
  end
end
