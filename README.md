# Console Buddy

Have you ever had debugging tricks, aliases, or shortcuts that don't make sense as application code but, are super helpful in the console? Console Buddy allows you to define helpful console methods, shortcuts, and helpers. You can also use our built in suite of console helper methods

## Setup

Add this line to your application's Gemfile:

```ruby
gem 'console_buddy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install console_buddy

## Important: Conditional Loading

**Console Buddy will only load if there is a `.console_buddy/` directory in the root of your project** (at the same level as your Gemfile). This is a safety feature that ensures the gem doesn't unnecessarily load in projects that don't use it.

If the `.console_buddy/` directory doesn't exist, the gem will silently return without loading any of its functionality. This means you can safely include Console Buddy in your Gemfile without worrying about it affecting projects that don't have console buddy configurations.

## Basic Usage
1. Create your `.console_buddy/` directory in the root of your project. (If you have a rails app the .console_buddy directory should be a sibling to app/)
2. Add a config.rb file to the .`console_buddy/` directory. (More info on configuration below)
3. Create defintion files inside the ``.console_buddy/`` directory so that you can start using shortcuts
Example:
```ruby
# .console_buddy/class_helpers.rb

ConsoleBuddy::Augment.define do
  method User, :created_at_and_updated_at do |args|
    puts "#{self.created_at} | #{self.updated_at}"
  end

  method User, :last_user_log, type: :class do |args|
    self.joins(:logs).last
  end

  method_alias User, :bank_account_transaction_logs, :bat_logs

  method_alias Device, :find, :get, type: :class
end
```
4. Now start your console session!
```
$ bundle exec rails c
```

## Project Structure and Setup
The home for all your console classes, helpers, and defintiions should be `.console_buddy/` directory.
This can hold things like your own helper classes, scripts, and buddy definitions.
Console buddy will recursively load any `.rb` file in that directory and its subdirectories.

***This directory needs to be in the root of your project**

The recommeded naming convetion for the directory is as follows. Please note you can name as you please, the only file that needs SPECIFIC naming is `config.rb`.
```
.console_buddy/
 |_ class_helpers.rb
 |_ console_helpers.rb
 |_ config.rb
 |_ my_thing_class_that_i_only_use_in_console.rb
 |_ helpers/
    |_ user_helpers.rb
    |_ admin_helpers.rb
 |_ jobs/
    |_ background_tasks.rb
 ....
app/
 |_controllers/
 |_models/
 ...

```

## Augment your app
### Introduction
`ConsoleBuddy::Augment` is a simple Domain-Specific Language (DSL) for defining helper methods on your Ruby classes, typically in a Rails application. It allows you to:

Add instance methods or class methods to an existing class without editing the original class file.

Alias existing methods for convenience or readability.
Keep your console shortcuts and helper methods neatly organized in one place.
The key concept is that you create a block of method definitions and aliases under the `ConsoleBuddy::Augment.define` call. 

*Each method or alias is recorded and can be dynamically injected into the target class at runtime.*

### Defining an augment block
**Parameters:**
- **klass:** The class you want to augment (e.g., User).
- **method_name:** The name of the new method (e.g., :sps).
- **type:** By default :instance, which defines an instance method. You can also specify :class to define a class method.
- **block:** The block contains the logic of your new method. When type: :instance, self references the instance of the class. When type: :class, self refers to the class itself.


*Below is an example of using the `method` keyword in the DSL. This will create a brand new method on the class or instance of that class*
```ruby
# .console_buddy/class_helpers.rb

ConsoleBuddy::Augment.define do
  method User, :sps do |args|
    saved_posts
  end
end
```
---
**Parameters:**
- **klass:** The class you want to augment (e.g., User).
- **method_name:** The existing method you want to alias (e.g., :bank_account_transaction_logs).
- **new_method_name:** The alias or new name (e.g., :bat_logs).
- **type:** Like above, can be :instance (default) or :class.

This creates a new method (:bat_logs) which simply calls the original `:bank_account_transaction_logs`.

*Here is an example of using the `method_alias` keyword in the DSL. This will alias an existing method on the class or instance of that class*

```ruby
# .console_buddy/class_helpers.rb

ConsoleBuddy::Augment.define do
  method_alias User, :bank_account_transaction_logs, :bat_logs
end

```


Usage in the rails console is the exact same as you would run any other method
```
> User.bat_logs
#=> [<User::BankAccountTransactionLog>]
```

---

#### Troubleshooting

***InvalidTypeError***

If you accidentally pass an invalid type to method or method_alias (something other than :instance or :class), you'll see an InvalidTypeError. Make sure type is one of the two valid symbols.

***Name Conflicts***

If you define a method that already exists on the class (or if you alias to an existing method name), Ruby will overwrite the existing definition with your new DSL method. This can lead to unexpected behavior, so choose method names carefully.

***Block Scope***

Remember that when type: :instance, the block's self is an instance of the class; when type: :class, self is the class itself.


## Add console helpers
### Introduction
`ConsoleBuddy::Helpers` provides a convenient way to define custom methods that can be invoked anywhere in your Rails console. When you define a method using this DSL, it becomes globally accessible as if it were a built-in command.

### Defining Console Methods
To create a new method that is globally available in the Rails console, use console_method:

```ruby
# .console_buddy/console_helpers.rb

ConsoleBuddy::Helpers.define do
  console_method :who_is_your_buddy? do |name|
    puts "My buddy is #{name}"
  end

  console_method :say_hi do
    puts "Hi!"
  end
end
```

*`console_method`: The DSL keyword that registers your method with the ConsoleBuddy system.*

**Parameters:**

- **method_name:** A symbol for your new console command (e.g., :call_api).
- **block:** The logic you want to execute whenever this console command is called.
Inside the block, you can expect any arguments you define (in the example above, status and message).

Usage in the rails console is the exact same as you would run any other built in method
```
> say_hi
#=> Hi!
```

---

#### Troubleshooting

***Name Collisions***

If you define a console command that uses the same name as another method or Ruby/Rails console helper, you may run into conflicts. Rename your method to avoid overwriting important functionality.

***Argument Handling***

Ensure that you define and pass the correct number of arguments in your console_method block. Missing arguments or additional arguments will raise ArgumentError.

***Scope & Dependencies***

If your method depends on certain Rails models or other libraries, make sure they are loaded before calling your custom console method (e.g., requiring them in an initializer or ensuring your Rails environment has autoloaded them).


## Built in functionality
There is a number of built in console methods and other tools that you can use out the box.


### `table_print(data, options = {})`
Prints a tabular view of a collection (e.g., ActiveRecord objects) to the console using **TablePrint**.

**Usage**
```ruby
> table_print(User.all, "username")
```

---

### `table_for(rows, headers = [])`
Renders a table from an array of arrays, optionally with column headers, using Terminal::Table

**Usage**
```ruby
> table_for([["foo", "bar"], ["baz", "qux"]], ["col1", "col2"])
```

---

### `ping(url)`
Makes a GET request to the specified URL and returns the parsed JSON response.

**Usage**  
```ruby
> ping("https://jsonplaceholder.typicode.com/posts/1")
```

---

### `generate_csv(headers, rows, filename: DateTime.now.to_s, dir: 'tmp')`
Generates a CSV file with the given headers and rows, saving it to the specified directory.

**Usage**  
```ruby
> generate_csv(
  ["Name", "Email"],
  [["Alice", "alice@example.com"], ["Bob", "bob@example.com"]],
  filename: "contacts",
  dir: "tmp"
)
```

---

### `read_csv(file_path, skip_headers: true)`
Reads a CSV file and returns its rows as an array.

**Usage**  
```ruby
> read_csv("tmp/contacts.csv", skip_headers: true)
```

---

### OneOff BackgroundJobs
This feature allows you to dynamically define and execute a process async using Sidekiq, ActiveJob or Resque. This is done 100% in the console.

**Usage**  
```ruby
> ConsoleBuddy::OneOffJob.define { User.all.each { |x| x.do_long_running_thing } }
> ConsoleBuddy::Job.perform_async
```

## Configurations and settings
All of these settings are straight forward and do what you think they would do. So I won't go into to much detail:
```ruby
# .console_buddy/config.rb

ConsoleBuddy.verbose_console = true # Should console buddy print out to the console during startup
ConsoleBuddy.use_in_tests = true # Do you want to load in your shortcuts and helpers when using RSpec?
ConsoleBuddy.use_in_debuggers = true # When in a debugger like byebug should the console buddy context be loaded in?
ConsoleBuddy.ignore_startup_errors = false # Should warnings and errors be ignored?
ConsoleBuddy.allowed_envs = ["development", "test"] # What RACK_ENV/RAILS_ENV do we want to use this in?
ConsoleBuddy.one_off_job_service_type = :sidekiq # What background job gem do you use? :sidekiq, :resque, and :active_job are supported
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
