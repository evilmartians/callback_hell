# frozen_string_literal: true

module ActsAsTaggable
  extend ActiveSupport::Concern

  included do
    after_commit :save_tags
    validate :validate_tags
  end

  def save_tags = true

  def validate_tags = true
end
