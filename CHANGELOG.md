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