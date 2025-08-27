# frozen_string_literal: true

RSpec.describe CallbackHell::Runner do
  let(:collector) { instance_double(CallbackHell::Collector) }
  let(:report) { instance_double(CallbackHell::Reports::Validations::Table) }

  before do
    allow(collector).to receive(:collect).and_return([])
    allow(report).to receive(:generate).and_return("Report output")
  end

  describe "#run" do
    it "class delegates to instance" do
      expect_any_instance_of(described_class).to receive(:run)
      described_class.run
    end

    context "with format handling" do
      before do
        allow(CallbackHell::Collector).to receive(:new).and_return(collector)
      end

      it "uses table format by default" do
        expect(CallbackHell::Reports::Callbacks::Table).to receive(:new)
          .with(any_args)
          .and_return(report)

        described_class.new(format: nil, model: nil, paths: nil, kind: :callbacks).run
      end

      it "uses correct namespace for validations" do
        expect(CallbackHell::Reports::Validations::Table).to receive(:new)
          .with(any_args)
          .and_return(report)

        described_class.new(format: nil, model: nil, paths: nil, kind: :validations).run
      end

      it "accepts format as string" do
        expect(CallbackHell::Reports::Callbacks::Github).to receive(:new)
          .with(any_args)
          .and_return(report)

        described_class.new(format: "github", model: nil, paths: nil, kind: :callbacks).run
      end

      it "raises error for unknown format" do
        expect {
          described_class.new(format: :unknown, model: nil, paths: nil, kind: :callbacks).run
        }.to raise_error(CallbackHell::Error, /Unknown format/)
      end
    end

    context "with combined report" do
      let(:callbacks_collector) { instance_double(CallbackHell::Collector) }
      let(:validations_collector) { instance_double(CallbackHell::Collector) }
      let(:callbacks_report) { instance_double(CallbackHell::Reports::Callbacks::Table) }
      let(:validations_report) { instance_double(CallbackHell::Reports::Validations::Table) }
      let(:model_class) { Class.new }

      before do
        allow(CallbackHell::Collector).to receive(:new)
          .with(anything, hash_including(kind: :callbacks)).and_return(callbacks_collector)
        allow(CallbackHell::Collector).to receive(:new)
          .with(anything, hash_including(kind: :validations)).and_return(validations_collector)

        allow(callbacks_collector).to receive(:collect).and_return([])
        allow(validations_collector).to receive(:collect).and_return([])

        allow(CallbackHell::Reports::Callbacks::Table).to receive(:new)
          .and_return(callbacks_report)
        allow(CallbackHell::Reports::Validations::Table).to receive(:new)
          .and_return(validations_report)

        allow(callbacks_report).to receive(:generate).and_return("Callbacks report")
        allow(validations_report).to receive(:generate).and_return("Validations report")
      end

      it "generates both reports when kind is :report" do
        output = described_class.new(format: :table, model: nil, paths: nil, kind: :report).run

        expect(output).to eq("Callbacks report\n\nValidations report")
      end

      it "passes the model parameter to both collectors" do
        stub_const("User", model_class)
        runner = described_class.new(format: :table, model: "User", paths: nil, kind: :report)

        expect(CallbackHell::Collector).to receive(:new)
          .with(model_class, hash_including(kind: :callbacks))
          .and_return(callbacks_collector)
        expect(CallbackHell::Collector).to receive(:new)
          .with(model_class, hash_including(kind: :validations))
          .and_return(validations_collector)

        runner.run
      end

      it "passes the paths parameter to both collectors" do
        paths = [Rails.root.join("extra")]

        expect(CallbackHell::Collector).to receive(:new)
          .with(nil, hash_including(paths: paths, kind: :callbacks))
          .and_return(callbacks_collector)
        expect(CallbackHell::Collector).to receive(:new)
          .with(nil, hash_including(paths: paths, kind: :validations))
          .and_return(validations_collector)

        described_class.new(format: :table, model: nil, paths: paths, kind: :report).run
      end
    end

    context "with model resolution" do
      before do
        allow(CallbackHell::Reports::Callbacks::Table).to receive(:new).and_return(report)
        allow(CallbackHell::Collector).to receive(:new).and_return(collector)
      end

      it "accepts constant name" do
        expect(CallbackHell::Collector).to receive(:new).with(Foo, paths: nil, kind: :callbacks, mode: :default)

        described_class.new(format: nil, model: "Foo", paths: nil, kind: :callbacks).run
      end

      it "accepts file path and converts to constant" do
        stub_const("Admin::User", Class.new)
        expect(CallbackHell::Collector).to receive(:new).with(Admin::User, paths: nil, kind: :callbacks, mode: :default)

        described_class.new(format: nil, model: "admin/user", paths: nil, kind: :callbacks).run
      end

      it "fails when model cannot be found" do
        expect {
          described_class.new(format: nil, model: "NonExistent", paths: nil, kind: :callbacks).run
        }.to raise_error(CallbackHell::Error, /Cannot find model/)
      end
    end
  end
end
