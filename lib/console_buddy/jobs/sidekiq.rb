# frozen_string_literal: true

require_relative "../one_off_job"

# Example Usage: ConsoleBuddy::Jobs::Sidekiq.perform_later("foo", "bar")
# 
# This class is used to integrate the ConsoleBuddy::OneOffJob with Sidekiq.
module ConsoleBuddy
  module Jobs
    class Sidekiq
      include(defined?(::Sidekiq::Worker) ? ::Sidekiq::Worker : ::Sidekiq::Job)

      def perform(*args)
        ::ConsoleBuddy::OneOffJob.perform(*args)
      end
    end
  end
end
