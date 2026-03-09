# frozen_string_literal: true


# Example:
# 
# Here we are defining a method called `sps` on the `User` model.
# This method will return the saved posts for a given user record.
# 
# 
# ConsoleBuddy::Augment.define do
#   method User, :sps do |args|
#     saved_posts
#   end
# end

module ConsoleBuddy
  class Augment
    class << self
      def define(&block)
        if block_given?
          instance = ::ConsoleBuddy::Augment::DSL.new
          instance.instance_eval(&block)
          ConsoleBuddy.augment_classes if ConsoleBuddy.respond_to?(:augment_classes)
        end
      end
    end

    class DSL
      class InvalidTypeError < StandardError; end

      def method(klass, method_name, type: :instance, &block)
        raise InvalidTypeError, "Invalid method type. Must be either :instance or :class" unless %i[instance class].include?(type)

        store(klass) <<  { method_name: method_name, block: block, method_type: type }
      end

      def method_alias(klass, method_name, new_method_name, type: :instance)
        raise InvalidTypeError, "Invalid method type. Must be either :instance or :class" unless %i[instance class].include?(type)

        block = ::Proc.new { |*args| send(method_name, *args) }
        store(klass) <<  { method_name: new_method_name, block: block, method_type: type }
      end

      private

      def store(klass)
        ConsoleBuddy.store.augment_helper_methods[klass.to_s]
      end
    end
  end
end
