# frozen_string_literal: true

module Annoying
  extend ActiveSupport::Concern

  included do
    after_commit :be_annoying
    validate :be_annoying
  end

  def be_annoying
    true
  end
end
