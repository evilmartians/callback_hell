# frozen_string_literal: true

require "rake"
require "rails"

namespace :ch do
  desc <<~DESC
    Generate callbacks report for Active Record models.

    Options:
      format=table|line|github   Report format (default: table)
      model=ModelName            Filter by model name (optional). Can be
                                 specified as constant
                                 name (MessageThread) or file path
                                 (message_thread, admin/message_thread)
      sort=total|name            Sort by score or name (default: score:desc)
      mode=default|full          Default mode collects only user-defined callbacks,
                                 full includes association-, attribute-, or validation-generated
                                 callbacks
      path=DIR1,DIR2             Additional model directories (comma-separated)

    Examples:
      # Show all models callbacks in table format (default)
      rake ch:callbacks
  DESC
  task callbacks: :environment do
    opts = {
      kind: :callbacks,
      format: ENV["format"],
      model: ENV["model"],
      mode: :default
    }.compact

    if ENV["path"]
      opts[:paths] = ENV["path"]&.split(",")&.map { |p| Rails.root.join(p) }
    end

    if ENV["sort"]
      sort_by, sort_order = ENV["sort"].split(":")
      opts[:sort_by] = sort_by.to_sym
      sort_order ||= ((sort_by == "size") ? :desc : :asc)
      opts[:sort_order] = sort_order.to_sym
    end

    if ENV["mode"]
      raise ArgumentError, "Mode must be either default or full" unless ENV["mode"].in?(%w[default full])
      opts[:mode] = ENV["mode"].to_sym
    end

    puts CallbackHell::Runner.run(**opts)
  end

  desc <<~DESC
    Generate validations report for Active Record models.

    Options:
      format=table|line|github   Report format (default: table)
      model=ModelName            Filter by model name (optional). Can be
                                 specified as constant
                                 name (MessageThread) or file path
                                 (message_thread, admin/message_thread)
      sort=total|name            Sort by score or name (default: score:desc)
      mode=default|full          Default mode collects only user-defined validations,
                                 full includes association- or attribute-generated
                                 validations
      path=DIR1,DIR2             Additional model directories (comma-separated)

    Examples:
      # Show all models validations in table format (default)
      rake ch:validations
  DESC
  task validations: :environment do
    opts = {
      kind: :validations,
      format: ENV["format"],
      model: ENV["model"]
    }.compact

    if ENV["path"]
      opts[:paths] = ENV["path"]&.split(",")&.map { |p| Rails.root.join(p) }
    end

    if ENV["sort"]
      sort_by, sort_order = ENV["sort"].split(":")
      opts[:sort_by] = sort_by.to_sym
      sort_order ||= ((sort_by == "size") ? :desc : :asc)
      opts[:sort_order] = sort_order.to_sym
    end

    if ENV["mode"]
      raise ArgumentError, "Mode must be either default or full" unless ENV["mode"].in?(%w[default full])
      opts[:mode] = ENV["mode"].to_sym
    end

    puts CallbackHell::Runner.run(**opts)
  end

  desc <<~DESC
    Generate combined report (callbacks and validations) for Active Record models.

    Options:
      format=table|line|github   Report format (default: table)
      model=ModelName            Filter by model name (optional). Can be
                                 specified as constant
                                 name (MessageThread) or file path
                                 (message_thread, admin/message_thread)
      sort=total|name            Sort by score or name (default: score:desc)
      mode=default|full          Default mode collects only user-defined callbacks,
                                 full includes association-, attribute-, or validation-generated
                                 callbacks/validations
      path=DIR1,DIR2             Additional model directories (comma-separated)

    Examples:
      rake ch:report
  DESC
  task report: :environment do
    opts = {
      kind: :report,
      format: ENV["format"],
      model: ENV["model"]
    }.compact

    if ENV["path"]
      opts[:paths] = ENV["path"]&.split(",")&.map { |p| Rails.root.join(p) }
    end

    if ENV["sort"]
      sort_by, sort_order = ENV["sort"].split(":")
      opts[:sort_by] = sort_by.to_sym
      sort_order ||= ((sort_by == "size") ? :desc : :asc)
      opts[:sort_order] = sort_order.to_sym
    end

    if ENV["mode"]
      raise ArgumentError, "Mode must be either default or full" unless ENV["mode"].in?(%w[default full])
      opts[:mode] = ENV["mode"].to_sym
    end

    puts CallbackHell::Runner.run(**opts)
  end
end

# Top-level convenience task
desc "Generate callback and validation analysis report"
task ch: "ch:report"
