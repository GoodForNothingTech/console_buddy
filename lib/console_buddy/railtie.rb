# frozen_string_literal: true

require 'rails/railtie'

# Load console buddy when the Rails console is started
module ConsoleBuddy
  class Railtie < ::Rails::Railtie
    # Queue linters and Sidekiq boot load worker classes without running `rails console`, so
    # `.console_buddy/config.rb` never runs. Set CONSOLE_BUDDY_SIDEKIQ_QUEUE to an allowed queue name
    # (e.g. in .env or your process manager) so ConsoleBuddy::Jobs::Sidekiq is not registered on `default`.
    initializer "console_buddy.sidekiq_queue_from_env" do
      next unless defined?(::ConsoleBuddy::Jobs::Sidekiq)

      queue = ENV["CONSOLE_BUDDY_SIDEKIQ_QUEUE"].to_s.strip
      next if queue.empty?

      ::ConsoleBuddy::Jobs::Sidekiq.sidekiq_options queue: queue.to_sym
    end

    console do
      ::ConsoleBuddy.start!
    end
  end
end

require "console_buddy/railtie" if defined?(::Rails::Railtie)