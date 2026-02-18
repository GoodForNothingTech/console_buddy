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