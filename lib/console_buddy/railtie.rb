# frozen_string_literal: true

require 'rails/railtie'

# Load console buddy when the Rails console is started
module ConsoleBuddy
  class Railtie < ::Rails::Railtie
    # Queue linters and Sidekiq boot load worker classes without running `rails console`, so
    # `.console_buddy/config.rb` never runs. Set CONSOLE_BUDDY_SIDEKIQ_QUEUE to an allowed queue name
    # (e.g. in .env or your process manager) so ConsoleBuddy::Jobs::Sidekiq is not registered on `default`.
    #
    # NOTE: ConsoleBuddy::Jobs::Sidekiq is only loaded during start! (console sessions). For all other
    # processes (Sidekiq workers, CI) we load it here directly when the env var is present so the
    # queue option is applied before Sidekiq introspects the worker class on boot.
    initializer "console_buddy.sidekiq_queue_from_env" do
      queue = ENV["CONSOLE_BUDDY_SIDEKIQ_QUEUE"].to_s.strip
      next if queue.empty?

      unless defined?(::ConsoleBuddy::Jobs::Sidekiq)
        begin
          require 'sidekiq'
          require_relative "jobs/sidekiq"
        rescue LoadError
          next
        end
      end

      ::ConsoleBuddy::Jobs::Sidekiq.sidekiq_options queue: queue.to_sym
    end

    console do
      ::ConsoleBuddy.start!
    end
  end
end

require "console_buddy/railtie" if defined?(::Rails::Railtie)