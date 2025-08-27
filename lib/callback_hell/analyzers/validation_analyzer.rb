# frozen_string_literal: true

module CallbackHell
  module Analyzers
    class ValidationAnalyzer
      STANDARD_VALIDATIONS = %w[
        presence uniqueness format length inclusion exclusion
        numericality acceptance confirmation
      ].freeze

      STANDARD_VALIDATION_PATTERN = /^validates?_(#{STANDARD_VALIDATIONS.join("|")})(?:_of)?$/

      class << self
        def belongs_to_validator?(filter, model)
          presence_validator?(filter) &&
            association_attribute?(filter.attributes.first, model, :belongs_to)
        end

        def detect_type(filter, model)
          return nil unless filter

          if belongs_to_validator?(filter, model)
            "associated"
          elsif validator?(filter)
            validator_type(filter)
          else
            normalize_validation_name(filter.to_s)
          end
        end

        def human_method_name(filter)
          case filter
          when Proc then format_proc_location(filter)
          when Class, ActiveModel::Validator then format_validator(filter)
          else filter.to_s
          end
        end

        private

        def presence_validator?(filter)
          filter.is_a?(ActiveRecord::Validations::PresenceValidator)
        end

        def association_attribute?(attribute, model, macro)
          model.reflect_on_association(attribute)&.macro == macro
        end

        def validator?(obj)
          obj.class <= ActiveModel::EachValidator
        end

        def validator_type(validator)
          validator.class.name.demodulize.sub("Validator", "").underscore
        end

        def normalize_validation_name(name)
          case name
          when STANDARD_VALIDATION_PATTERN, /^validate_(#{STANDARD_VALIDATIONS.join("|")})$/
            $1
          when /associated_records_for_/
            "associated"
          else
            "custom"
          end
        end

        def format_proc_location(proc)
          location = proc.source_location
          return "Proc (unknown location)" unless location

          file = location.first.split("/").last(2).join("/")
          "Proc (#{file}:#{location.last})"
        end

        def format_validator(validator)
          "#{validator.class.name.split("::").last} (#{validator.attributes.join(", ")})"
        end
      end
    end
  end
end
