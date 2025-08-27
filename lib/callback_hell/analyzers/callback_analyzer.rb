# frozen_string_literal: true

module CallbackHell
  module Analyzers
    class CallbackAnalyzer
      RAILS_GEMS = %w[
        actioncable actionmailbox actionmailer actionpack actiontext
        actionview activejob activemodel activerecord activestorage
        activesupport railties
      ].freeze

      RAILS_ATTRIBUTE_OWNERS = [
        defined?(ActiveRecord::Normalization) ? ActiveRecord::Normalization : ActiveModel::Attributes::Normalization,
        ActiveRecord::Encryption::EncryptableRecord
      ].freeze

      def initialize(callback, model, defining_class)
        @callback = callback
        @model = model
        @defining_class = defining_class
        @filter = callback.filter
      end

      def origin
        if rails_callback?
          :rails
        elsif external_class?
          :gems
        elsif !@filter.is_a?(Symbol)
          :own
        else
          external_method?(callback_method) ? :gems : :own
        end
      end

      def inherited?
        @model != @defining_class
      end

      def conditional?
        [@callback.instance_variable_get(:@if),
          @callback.instance_variable_get(:@unless)].any? do |condition|
          next false if condition.nil?
          [*condition].any? { |c| c.is_a?(Symbol) || c.is_a?(Proc) }
        end
      end

      def association_generated?
        generated_by_module?("GeneratedAssociationMethods") ||
          from_rails_path?(%r{/active_record/(autosave_association\.rb|associations/builder)}) ||
          ValidationAnalyzer.belongs_to_validator?(@filter, @model)
      end

      def attribute_generated?
        generated_by_module?("GeneratedAttributeMethods") ||
          generated_by_rails_attributes? ||
          from_rails_path?("active_record/attribute_methods/")
      end

      private

      def rails_callback?
        ValidationAnalyzer.belongs_to_validator?(@filter, @model) || standard_rails_callback?
      end

      def standard_rails_callback?
        case @filter
        when Symbol, Proc then from_rails_path?
        else @defining_class == ApplicationRecord
        end
      end

      def callback_owner
        @callback_owner ||= determine_owner
      end

      def determine_owner
        case @filter
        when Symbol then callback_method&.owner
        when Proc then nil
        when ActiveModel::Validator, ActiveModel::EachValidator then @defining_class
        else @filter.class
        end
      end

      def callback_method
        return nil unless @filter.is_a?(Symbol) || @filter.is_a?(String)

        @callback_method ||= begin
          @model.instance_method(@filter)
        rescue
          nil
        end
      end

      def source_location
        @source_location ||= case @filter
        when Symbol, String then callback_method&.source_location&.first
        when Proc then @filter.source_location&.first
        end.to_s
      end

      def external_class?
        @defining_class != @model && !@model.ancestors.include?(@defining_class)
      end

      def external_method?(method)
        return false unless method

        source = method.source_location&.first.to_s
        !from_app_path?(source)
      end

      def from_app_path?(path)
        path.start_with?(Rails.root.to_s) &&
          !path.start_with?(Rails.root.join("vendor").to_s)
      end

      def generated_by_module?(suffix)
        callback_method&.owner&.name&.end_with?("::" + suffix) || false
      end

      def generated_by_rails_attributes?
        method = callback_method
        return false unless method

        RAILS_ATTRIBUTE_OWNERS.include?(method.owner)
      end

      def from_rails_path?(subpath = nil)
        return false if source_location.empty?

        rails_paths.any? do |rails_path|
          case subpath
          when String
            source_location.include?("/#{subpath}")
          when Regexp
            source_location.match?(subpath)
          else
            source_location.include?(rails_path)
          end
        end
      end

      def rails_paths
        @rails_paths ||= RAILS_GEMS.map { |name| Gem::Specification.find_by_name(name).full_gem_path }
      end

      def rails_module?(mod)
        mod.name&.start_with?("ActiveRecord::", "ActiveModel::")
      end

      def validator?(obj)
        obj.is_a?(ActiveModel::Validator)
      end
    end
  end
end
