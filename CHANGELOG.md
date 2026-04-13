## Console Buddy 0.2.0 (April 13, 2026) ##

* **[BREAKING]** One-off jobs disabled by default
- `ConsoleBuddy::OneOffJob`, `ConsoleBuddy::Job`, and all background job adapter files (Sidekiq, Resque, ActiveJob) are no longer loaded at gem require time.
- A new `ConsoleBuddy.enable_one_off_jobs` config flag (default: `false`) controls whether the feature is active. Set it to `true` in `.console_buddy/config.rb` to restore previous behaviour:
  ```ruby
  ConsoleBuddy.enable_one_off_jobs = true
  ```
- Apps that relied on one-off jobs without explicitly enabling this flag will have the feature silently disabled after upgrading. Update your `.console_buddy/config.rb` to opt in.

* Version Bump
- Bumped version to 0.2.0.

## Console Buddy 0.1.12 (April 3, 2026) ##

* Configurable Sidekiq queue for one-off jobs
- Added `ConsoleBuddy.one_off_job_sidekiq_queue`. When set (e.g. in `.console_buddy/config.rb`), it is applied to `ConsoleBuddy::Jobs::Sidekiq.sidekiq_options` when the console starts, and `perform_async` enqueues using that queue.
- Added `CONSOLE_BUDDY_SIDEKIQ_QUEUE` env support via Railtie so worker metadata is valid in Sidekiq/CI without relying on `rails console` to load `.console_buddy/config.rb`.

* Version Bump
- Bumped version to 0.1.12.

## Console Buddy 0.1.11 (March 8, 2026) ##

* Directory loading improvement for rails 7.2+
- Improve .console_buddy directory handling and loading logic for better compatibility with Rails and Pry


* Version Bump
- Bumped version to 0.1.11.

## Console Buddy 0.1.10 (February 17, 2026) ##

* Sidekiq Worker Inclusion Fix
- Fixed `wrong argument type Class (expected Module)` error when using Sidekiq 5.x. The inclusion now prefers `Sidekiq::Worker` (a Module in all versions) over `Sidekiq::Job`, which may be defined as a Class by other gems or the host app.

* Documentation Fix
- Removed incorrect `ConsoleBuddy::Report.table_print` and `ConsoleBuddy::Report.table_for` examples from inline comments and README. These are instance methods available directly in the console session.

* Version Bump
- Bumped version to 0.1.10.

## Console Buddy 0.1.9 (February 17, 2026) ##

* Progress Bar Frozen Object Fix
- Fixed startup crash caused by `progress_bar` gem attempting to patch frozen `Enumerable` modules via `ObjectSpace`. The require is now rescued gracefully so startup continues in Rails apps with frozen modules.

* Improved Error Logging
- Startup error handler now includes a backtrace (first 5 lines) for easier debugging.
- Fixed typo in error message: "encountered an during" -> "encountered an error during".

* Version Bump
- Bumped version to 0.1.9.

## Console Buddy 0.1.8 (February 17, 2026) ##

* Sidekiq Job Inclusion Fix
- Fixed Sidekiq job inclusion to support both `Sidekiq::Job` and `Sidekiq::Worker` based on availability.

* Gemspec Updates
- Updated repository URLs to point to the new GoodForNothingTech organization.
- Added additional author email.

* Version Bump
- Bumped version to 0.1.8.

## Console Buddy 0.1.7 (June 23, 2025) ##

* Conditionally Gem Loading
- The gem will only load if there is a .console_buddy directory in the root of the project. (Same level as the Gemfile)


## Console Buddy 0.1.6 (June 23, 2025) ##

* Enhanced File Loading
- Console buddy now recursively loads files from subdirectories within the `.console_buddy/` directory, allowing for better organization of console helpers and definitions.

## Console Buddy 0.1.5 (June 23, 2025) ##

* Bug fixes

## Console Buddy 0.1.4 (December 27, 2024) ##

* Bug fixes
- Console buddy was not properly loading in the test env or the debugger this is not been resolved.
- When using resque for one off jobs the job would be assigned to a queue that does not exist. This has been resolved.
- Documentation updates

## Console Buddy 0.1.0 (December 30, 2023) ##

*  Initial Release