# frozen_string_literal: true

require_relative "../one_off_job"

# Example Usage: ConsoleBuddy::Jobs::Sidekiq.perform_later("foo", "bar")
#
# This class is used to integrate the ConsoleBuddy::OneOffJob with Sidekiq.
# Set ConsoleBuddy.one_off_job_sidekiq_queue in .console_buddy/config.rb when your
# app forbids the default queue (e.g. queue governance / Sidekiq Pro).
module ConsoleBuddy
  module Jobs
    class Sidekiq
      include(defined?(::Sidekiq::Worker) ? ::Sidekiq::Worker : ::Sidekiq::Job)

      def perform(*args)
        ::ConsoleBuddy::OneOffJob.perform(*args)
      end

      class << self
        def perform_async(*args)
          q = configured_sidekiq_queue
          if q.present?
            if respond_to?(:set)
              set(queue: q).perform_async(*args)
            else
              push_with_queue(args, q)
            end
          else
            super
          end
        end

        private

        def configured_sidekiq_queue
          return unless defined?(::ConsoleBuddy) && ::ConsoleBuddy.respond_to?(:one_off_job_sidekiq_queue)

          q = ::ConsoleBuddy.one_off_job_sidekiq_queue
          return if q.nil? || (q.respond_to?(:empty?) && q.empty?)

          q.respond_to?(:to_sym) ? q.to_sym : q
        end

        def push_with_queue(args, queue)
          ::Sidekiq::Client.push(
            "class" => name,
            "args" => args,
            "queue" => queue.to_s
          )
        end
      end
    end
  end
end
