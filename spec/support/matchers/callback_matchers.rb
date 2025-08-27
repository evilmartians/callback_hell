# frozen_string_literal: true

# RSpec.describe "Rails default callbacks" do
#   let(:application_record) { ApplicationRecord }
#   let(:callbacks) { CallbackHell::Collector.new(application_record).collect }
#
#   it "has inherited callbacks from a module" do
#     expect(bar).to have_callback(
#       callback_name: :after_commit,
#       method_name: :be_annoying,
#       inherited: true
#     )
#   end
#
#   it "has default Rails callbacks" do
#     # Using glob pattern
#     expect(callbacks).to have_callback(
#       method_name: "*_encrypted_attributes_*",
#       origin: :rails,
#       inherited: :own
#     )
#
#     # Using regex
#     expect(callbacks).to have_callback(
#       method_name: /normalize_.*_attributes/,
#       origin: :rails,
#       inherited: :own
#     )
#   end
# end
#
#
# RSpec.describe "Rails default callbacks" do
#   let(:application_record) { ApplicationRecord }
#   let(:callbacks) { CallbackHell::Collector.new(application_record).collect }
#
#   it "has specific callbacks" do
#     # Complete absence of a callback
#     expect(callbacks).not_to have_callback(
#       method_name: "nonexistent_callback"
#     )
#
#     # Has a callback with specific attributes but different origin
#     expect(callbacks).to have_callback(
#       method_name: "*_encrypted_attributes_*"
#     ).but_with(origin: :own)
#
#     # More complex example
#     expect(callbacks).to have_callback(
#       method_name: /normalize_.*_attributes/,
#       origin: :rails
#     ).but_with(inherited: :inherited)
#   end
# end
RSpec::Matchers.define :have_callback do |expected|
  match do |callbacks|
    @callbacks = callbacks.is_a?(Array) ? callbacks : [callbacks]
    @mismatches = []

    @callbacks.any? do |callback|
      @current_callback = callback
      matches = expected.all? do |key, value|
        result = case key
        when :callback_name
          kind, group = value.to_s.split("_", 2)
          callback.kind.to_s == kind && callback.callback_group.to_s == group
        else
          actual = callback.public_send(key)
          case value
          when String, Symbol
            File.fnmatch?(value.to_s, actual.to_s)
          when Regexp
            value.match?(actual.to_s)
          else
            actual == value
          end
        end

        unless result
          actual = case key
          when :callback_name
            "#{callback.kind}_#{callback.callback_group}"
          else
            callback.public_send(key)
          end
          @mismatches << "#{key}: expected #{value.inspect}, got #{actual.inspect}"
        end

        result
      end

      if @but_with && matches
        matches = @but_with.all? do |key, value|
          actual = callback.public_send(key)
          result = actual.to_s != value.to_s
          @mismatches << "#{key}: expected not #{value.inspect}, got #{actual.inspect}" unless result
          result
        end
      end

      if matches
        @matching_callback = callback
        true
      else
        @mismatches << "---"
        false
      end
    end
  end

  chain :but_with do |additional|
    @but_with = additional
  end

  failure_message do |_callbacks|
    message = ["expected to find callback matching #{expected.inspect}"]
    message << "but with #{@but_with.inspect}" if @but_with
    message << "\nMismatches:"
    message += @mismatches.uniq
    message.join("\n")
  end
end
