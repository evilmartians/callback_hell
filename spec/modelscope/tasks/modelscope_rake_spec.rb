# frozen_string_literal: true

require "rake"

RSpec.describe "rake ch:callbacks" do
  let(:task_name) { "ch:callbacks" }

  before(:all) do
    Rake::Task.clear
    load "lib/tasks/callback_hell.rake"
  end

  around do |example|
    original_stdout = $stdout
    $stdout = StringIO.new
    example.run
    $stdout = original_stdout
  end

  it "runs with default parameters" do
    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :callbacks, mode: :default)

    Rake::Task[task_name].execute
  end

  it "accepts format parameter" do
    ENV["format"] = "line"

    expect(CallbackHell::Runner).to receive(:run)
      .with(format: "line", kind: :callbacks, mode: :default)

    Rake::Task[task_name].execute
  end

  it "accepts sort parameter" do
    ENV["sort"] = "name:asc"

    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :callbacks, sort_by: :name, sort_order: :asc, mode: :default)

    Rake::Task[task_name].execute
  end

  it "accepts partial sort" do
    ENV["sort"] = "size"

    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :callbacks, sort_by: :size, sort_order: :desc, mode: :default)

    Rake::Task[task_name].execute
  end

  it "accepts mode parameter" do
    ENV["mode"] = "full"

    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :callbacks, mode: :full)

    Rake::Task[task_name].execute
  end

  it "accepts model parameter" do
    ENV["model"] = "User"

    expect(CallbackHell::Runner).to receive(:run)
      .with(model: "User", kind: :callbacks, mode: :default)

    Rake::Task[task_name].execute
  end

  it "accepts path parameter and converts it to Rails paths" do
    ENV["path"] = "app/models,lib/models"

    expect(CallbackHell::Runner).to receive(:run)
      .with(
        paths: [Rails.root.join("app/models"), Rails.root.join("lib/models")],
        kind: :callbacks,
        mode: :default
      )

    Rake::Task[task_name].execute
  end

  it "accepts multiple parameters together" do
    ENV["format"] = "github"
    ENV["model"] = "Admin::User"
    ENV["path"] = "engines/admin/app/models"

    expect(CallbackHell::Runner).to receive(:run)
      .with(
        format: "github",
        model: "Admin::User",
        paths: [Rails.root.join("engines/admin/app/models")],
        kind: :callbacks,
        mode: :default
      )

    Rake::Task[task_name].execute
  end
end

RSpec.describe "rake ch:validations" do
  let(:task_name) { "ch:validations" }

  before(:all) do
    Rake::Task.clear
    load "lib/tasks/callback_hell.rake"
  end

  before do
    ENV.delete("format")
    ENV.delete("model")
    ENV.delete("path")
    ENV.delete("sort")
  end

  around do |example|
    original_stdout = $stdout
    $stdout = StringIO.new
    example.run
    $stdout = original_stdout
  end

  it "runs with default parameters" do
    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :validations)

    Rake::Task[task_name].execute
  end

  it "accepts format parameter" do
    ENV["format"] = "line"

    expect(CallbackHell::Runner).to receive(:run)
      .with(format: "line", kind: :validations)

    Rake::Task[task_name].execute
  end

  it "accepts model parameter" do
    ENV["model"] = "User"

    expect(CallbackHell::Runner).to receive(:run)
      .with(model: "User", kind: :validations)

    Rake::Task[task_name].execute
  end

  it "accepts path parameter and converts it to Rails paths" do
    ENV["path"] = "app/models,lib/models"

    expect(CallbackHell::Runner).to receive(:run)
      .with(
        paths: [Rails.root.join("app/models"), Rails.root.join("lib/models")],
        kind: :validations
      )

    Rake::Task[task_name].execute
  end
end

RSpec.describe "rake ch:report" do
  let(:task_name) { "ch:report" }

  before(:all) do
    Rake::Task.clear
    load "lib/tasks/callback_hell.rake"
  end

  before do
    ENV.delete("format")
    ENV.delete("model")
    ENV.delete("path")
  end

  around do |example|
    original_stdout = $stdout
    $stdout = StringIO.new
    example.run
    $stdout = original_stdout
  end

  it "runs with default parameters" do
    expect(CallbackHell::Runner).to receive(:run)
      .with(kind: :report)

    Rake::Task[task_name].execute
  end

  it "accepts format parameter" do
    ENV["format"] = "line"

    expect(CallbackHell::Runner).to receive(:run)
      .with(format: "line", kind: :report)

    Rake::Task[task_name].execute
  end

  it "accepts model parameter" do
    ENV["model"] = "User"

    expect(CallbackHell::Runner).to receive(:run)
      .with(model: "User", kind: :report)

    Rake::Task[task_name].execute
  end

  it "accepts path parameter and converts it to Rails paths" do
    ENV["path"] = "app/models,lib/models"

    expect(CallbackHell::Runner).to receive(:run)
      .with(
        paths: [Rails.root.join("app/models"), Rails.root.join("lib/models")],
        kind: :report
      )

    Rake::Task[task_name].execute
  end
end

RSpec.describe "rake ch (default task)" do
  it "runs the report task as default" do
    Rake::Task.clear
    load "lib/tasks/callback_hell.rake"

    task = Rake::Task["ch"]
    expect(task).to be_present
    expect(task.prerequisites).to include("ch:report")
  end
end
