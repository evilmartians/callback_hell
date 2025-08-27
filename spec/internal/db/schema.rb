# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :foos, force: true do |t|
    t.string :name
    t.string :title
  end

  create_table :bars, force: true do |t|
    t.references :foo
    t.string :name
  end
end
