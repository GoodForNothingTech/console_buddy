# frozen_string_literal: true

require "spec_helper"
require "sidekiq"
require_relative "../../../lib/console_buddy/jobs/sidekiq"

RSpec.describe ConsoleBuddy::Jobs::Sidekiq do
  describe ".perform_async" do
    after { ConsoleBuddy.one_off_job_sidekiq_queue = nil }

    context "when ConsoleBuddy.one_off_job_sidekiq_queue is set" do
      before { ConsoleBuddy.one_off_job_sidekiq_queue = :general_2m }

      it "uses Sidekiq set(queue:) when available" do
        setter = double("sidekiq_setter")
        expect(described_class).to receive(:set).with(queue: :general_2m).and_return(setter)
        expect(setter).to receive(:perform_async).with("a", 1)
        described_class.perform_async("a", 1)
      end
    end

  end
end
