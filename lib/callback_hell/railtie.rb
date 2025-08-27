# frozen_string_literal: true

module CallbackHell
  class Railtie < ::Rails::Railtie
    load "tasks/callback_hell.rake"
  end
end
