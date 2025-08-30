# Cutter

Cutter is a Ruby library that implements the circuit breaker design pattern, so your application will be more stable even if your 3rd party application is having problems.

With the Cutter library, your Ruby application will remain stable even if a connected third-party application experiences problems. This library implements the circuit breaker design pattern; in other words, it protects your application from system failures caused by external factors.

## High Flow
potential problems when 3rdparty applications experience problems : 
![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-problem.jpg)

circuit breaker solution to prevent system failure due to problematic 3rdparty applications :
![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-solution.jpg)

## Installation

The minimum version of Ruby that must be installed is 3.0.

Add this line to your application's Gemfile :

```ruby
gem 'cutter', git: 'git@github.com:solehudinmq/cutter.git', branch: 'main'
```

Open terminal, and run this : 
```bash
cd your_ruby_application
bundle install
```

## Usage

In your ruby ​​code, add this:
```ruby
require 'cutter'
```

Add this to initial library : 
```ruby
cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 5)
```
description of parameters:
- maximum_failure_limit = is the maximum failure limit when the state is closed. If the failure exceeds the maximum_failure_limit then the state will change to open. Example : 3 (meaning 3 times failed).
- waiting_time = is the waiting time when the state is open, if it exceeds this waiting time then the state will change to half open. Example : 5 (This means the waiting time from state open to half open is 5 seconds).

How to call 3rdparty API : 
```ruby
5.times do |i|
    puts "==> Try to-#{i + 1}"
    begin
        response = cb.run do
            # call api third party here
        end
        # your logic here
    rescue => e
        # your error response here
    end
    puts "\n"
    sleep(1) # Wait 1 second between attempts.
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/cutter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
