# frozen_string_literal: true

# RSpec.describe "Validations" do
#   let(:callbacks) { CallbackHell::Collector.new(model, kind: :validations).collect }

#   it "has presence validation" do
#     expect(callbacks).to have_validation(
#       type: "presence",
#       method_name: "validates_presence_of"
#     )
#   end

#   it "has custom validation" do
#     expect(callbacks).to have_validation(
#       type: "custom",
#       inherited: true
#     )
#   end

#   # With negation
#   it "has presence validation but not inherited" do
#     expect(callbacks).to have_validation(
#       type: "presence"
#     ).but_with(inherited: true)
#   end
# end
RSpec::Matchers.define :have_validation do |expected|
  match do |callbacks|
    @callbacks = callbacks.is_a?(Array) ? callbacks : [callbacks]
    @mismatches = []

    @callbacks.any? do |callback|
      next unless callback.callback_group == "validate"
      @current_callback = callback

      matches = expected.all? do |key, value|
        result = case key
        when :type
          callback.validation_type.to_s == value.to_s
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
          when :type
            callback.validation_type
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
    message = ["expected to find validation matching #{expected.inspect}"]
    message << "but with #{@but_with.inspect}" if @but_with
    message << "\nMismatches:"
    message += @mismatches.uniq
    message.join("\n")
  end
end
