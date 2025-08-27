# frozen_string_literal: true

require_relative "../../vendor/gems/acts_as_taggable/acts_as_taggable"

class Bar < ApplicationRecord
  include Annoying
  include ActsAsTaggable

  belongs_to :foo, optional: false # for whatever reason, I had to add the optional option

  validates :name, presence: true

  after_commit :noop

  def noop
    true
  end
end
