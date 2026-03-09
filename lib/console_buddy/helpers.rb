# frozen_string_literal: true

# Example usage
# 
# ConsoleBuddy::Helpers.define do
#   console_method :call_api do |status, message|
#     puts "making api call"

#     puts "RESPONSE: { #{status}, #{message} }"
#   end
# end

# $ call_api(200, "ok")
# 
#  call_api can be used anywhere in your rails console
# 
module ConsoleBuddy
  class Helpers
    class << self
      def define(&block)
        if block_given?
          instance = ::ConsoleBuddy::Helpers::DSL.new
          instance.instance_eval(&block)
          ConsoleBuddy.augment_console if ConsoleBuddy.respond_to?(:augment_console)
        end
      end
    end

    class DSL
      def console_method(method_name, &block)
        ::ConsoleBuddy.store.console_method[method_name] = block
        nil
      end
    end
  end
end

