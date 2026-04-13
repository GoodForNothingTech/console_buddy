# frozen_string_literal: true

require_relative "csv"
require_relative "http_request"
require_relative "report"

module ConsoleBuddy
  module IRB
    include ::ConsoleBuddy::CSV
    include ::ConsoleBuddy::HttpRequest
    include ::ConsoleBuddy::Report

    # This method is used to define a method on the `Object` class.
    # This method will return a new instance of the `ConsoleBuddy::Base` class.
    # Example Usage:
    # buddy.table_for(User.all)
    def buddy
      ::ConsoleBuddy::Base.new
    end
    alias console_buddy buddy
  end
end
