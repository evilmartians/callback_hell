# frozen_string_literal: true

class Foo < ApplicationRecord
  has_many :bars, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  validates :title, presence: true, if: :worthy?

  before_validation :noop
  after_validation :noop

  before_create :noop
  after_create :noop
  around_create :noop, if: :createable?

  normalizes :name, with: -> { _1.strip }

  def noop = true

  def createable? = true

  def worthy? = true
end
