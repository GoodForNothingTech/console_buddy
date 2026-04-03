# frozen_string_literal: true

require 'pathname'

# Always load the module; .console_buddy existence is checked in start! when Rails.root is set
# (Rails 7.2 / Spring can require gems before Rails.root is available)
require 'active_support'
require 'active_support/all'

require_relative "console_buddy/method_store"
require_relative "console_buddy/augment"
require_relative "console_buddy/base"
require_relative "console_buddy/helpers"
require_relative "console_buddy/irb"
require_relative "console_buddy/version"

require_relative "console_buddy/one_off_job"
require_relative "console_buddy/job"

rspec_present = false
# Only load the one-off job classes if the gems are installed
# 
begin
  require 'sidekiq'
  require_relative "console_buddy/jobs/sidekiq"
rescue LoadError
  # puts "Sidekiq gem not installed, skipping sidekiq job integration."
end

begin
  require 'resque'
  require_relative "console_buddy/jobs/resque"
rescue LoadError
  # puts "Resque gem not installed, skipping resque job integration."
end

begin
  require 'activejob'
  require_relative "console_buddy/jobs/active_job"
rescue LoadError
  # puts "ActiveJob gem not installed, skipping active job integration."
end

begin
  require 'rspec'
  rspec_present = true
rescue LoadError
  rspec_present = false
  # puts "RSpec gem not installed, skipping rspec integration."
end

module ConsoleBuddy
  class << self
    attr_accessor :verbose_console, :allowed_envs, :use_in_debuggers, :ignore_startup_errors, :use_in_tests, :one_off_job_service_type,
                  :one_off_job_sidekiq_queue

    def store
      @store ||= ::ConsoleBuddy::MethodStore.new
    end

    def start!
      # Initialize the default values
      set_config_defaults
      # Require .console_buddy to exist (check here when Rails.root is set; avoids Rails 7.2 / Spring load-order issues)
      return unless console_buddy_directory_exists?
      # Check if there is a .console_buddy/config file
      load_console_buddy_config
      apply_sidekiq_queue_to_worker

      # Only start the buddy in the allowed environments. e.g. development, test
      return if !allowed_env?

      # Do not start the buddy in test environment if use_in_tests is false
      return if test? && !use_in_tests

      begin
        load_console_buddy_files
        augment_classes
        augment_console
        start_buddy_in_irb
        start_buddy_in_rails
        start_buddy_in_byebug
        puts "ConsoleBuddy session started! Debugger: #{use_in_debuggers} | Test: #{current_env}" if verbose_console
      rescue ::StandardError => error
        unless ignore_startup_errors
          puts "ConsoleBuddy encountered an error during startup. [Error]: #{error.message}"
          puts error.backtrace.first(5).join("\n")
        end
      end
    end

    def load_byebug!
      start_buddy_in_byebug
    end

    private

    def set_config_defaults
      @verbose_console = true
      @use_in_tests = false
      @use_in_debuggers = false
      @ignore_startup_errors = false
      @allowed_envs = %w[development test]
      @one_off_job_service_type = :inline
      @one_off_job_sidekiq_queue = nil
    end

    # Only start the buddy in the allowed environments
    def allowed_env?
      if current_env.present?
        can_start = allowed_envs.include?(current_env)
        if verbose_console && can_start
          puts "ConsoleBuddy is starting in #{current_env} environment."
        end
        return can_start
      end

      true
    end

    def test?
      current_env == 'test'
    end

    def current_env
      ENV['RAILS_ENV'] || ENV['RACK_ENV']
    end

    # App root so .console_buddy is found under Rails (e.g. with Spring) or Dir.pwd
    def console_buddy_root
      if defined?(Rails) && Rails.respond_to?(:root) && Rails.root.present?
        Pathname.new(Rails.root.to_s)
      else
        Pathname.new(Dir.pwd)
      end
    end

    def console_buddy_directory_exists?
      console_buddy_root.join('.console_buddy').exist? && console_buddy_root.join('.console_buddy').directory?
    end

    # Loads the .console_buddy/config file if present
    def load_console_buddy_config
      config_path = console_buddy_root.join('.console_buddy', 'config.rb')
      if config_path.exist? && config_path.file?
        require config_path.to_s
      else
        puts ".console_buddy/config file not found."
      end
    end

    # Sync Sidekiq worker metadata so queue auditors and Sidekiq see a real queue (not the default queue).
    def apply_sidekiq_queue_to_worker
      return unless defined?(::ConsoleBuddy::Jobs::Sidekiq)

      q = ConsoleBuddy.one_off_job_sidekiq_queue
      return if q.blank?

      ::ConsoleBuddy::Jobs::Sidekiq.sidekiq_options queue: q.to_sym
    end

    # Loads all the files in the .console_buddy folder
    # .console_buddy folder should be in the root of the project
    def load_console_buddy_files
      console_buddy_path = console_buddy_root.join('.console_buddy')
      if console_buddy_path.exist? && console_buddy_path.directory?
        console_buddy_path.find do |path|
          next unless path.file?
          next if path.basename.to_s == 'config.rb' # Skip config.rb as it's loaded separately
          require path.to_s
        end
      else
        puts ".console_buddy folder not found in the root of the project."
      end
    end

    # Augment the classes with the methods defined in the store
    def augment_classes
      ::ConsoleBuddy.store.augment_helper_methods.each do |klass, methods|
        begin
          klass.constantize
        rescue NameError
          puts "Class #{klass} not found. Skipping..." if verbose_console
          next
        end

        methods.each do |method|
          case method[:method_type]
          when :instance
            klass.constantize.define_method(method[:method_name]) do |*args|
              instance_exec(*args, &method[:block])
            end
          when :class
            klass.constantize.define_singleton_method(method[:method_name]) do |*args|
              instance_exec(*args, &method[:block])
            end
          else
            next
          end
        end
      end
    end

    # Augment the console with the methods defined in the store
    def augment_console
      ::ConsoleBuddy.store.console_method.each do |method_name, block|
        ::ConsoleBuddy::IRB.define_method(method_name, block)
      end
    end

    public :augment_classes, :augment_console

    # This will add the buddy methods to the IRB session
    # So that they can be called without instantiating the `ConsoleBuddy::Base` class
    def start_buddy_in_irb
      if defined? IRB::ExtendCommandBundle
        IRB::ExtendCommandBundle.include(ConsoleBuddy::IRB)
        load_progress_bar
      end
    end

    # This will add the buddy methods to the Rails console
    # So that they can be called without instantiating the `ConsoleBuddy::Base` class
    def start_buddy_in_rails
      if defined? Rails::ConsoleMethods
        Rails::ConsoleMethods.include(ConsoleBuddy::IRB)
        load_progress_bar
      end
      # Pry: ensure console methods are on the session's main object (before_session gets output, binding, pry)
      if defined?(Pry)
        Pry.config.hooks.add_hook(:before_session, :console_buddy) do |_output, binding, _pry|
          binding.receiver.extend(ConsoleBuddy::IRB)
        end
      end
    end

    def load_progress_bar
      require 'progress_bar/core_ext/enumerable_with_progress'
    rescue StandardError
      # progress_bar iterates all Enumerable-including modules via ObjectSpace
      # and fails if any are frozen, which is common in Rails apps
    end

    # This will add the buddy methods to the Byebug console
    # TODO: Add support for Pry
    def start_buddy_in_byebug
      return if !use_in_debuggers

      if defined?(Byebug)
        byebug_path = Pathname.new(File.join(__dir__, 'console_buddy', 'byebug'))

        if byebug_path.exist? && byebug_path.directory?
          byebug_path.each_child do |file|
            next unless file.file?
            require file.to_s
          end
        end

        [
          ConsoleBuddy::Byebug::HelloCommand,
          ConsoleBuddy::Byebug::BuddyCommand,
        ].each do |command_class|
          ::Byebug.const_set(
            command_class.name.split('::').last,
            command_class,
          )
        end
      end
    end
  end
end

require_relative "console_buddy/initializers/byebug"
require_relative "console_buddy/initializers/rails"

if rspec_present
  require_relative "console_buddy/initializers/rspec"
end
