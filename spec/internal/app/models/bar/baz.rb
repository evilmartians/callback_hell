# frozen_string_literal: true

class Bar::Baz < ApplicationRecord
  before_save :noop

  def noop
    true
  end
end
