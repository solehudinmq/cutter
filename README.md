# Cutter

Cutter is a Ruby library that implements the circuit breaker design pattern, so your application will be more stable even if your 3rd party application is having problems.

With the Cutter library, your Ruby application will remain stable even if a connected third-party application experiences problems. This library implements the circuit breaker design pattern; in other words, it protects your application from system failures caused by external factors.

## High Flow

potential problems when 3rdparty applications experience problems : 

![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-problem.jpg)

circuit breaker solution to prevent system failure due to problematic 3rdparty applications :

![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-solution.jpg)

## Requirement

The minimum version of Ruby that must be installed is 3.0.

Requires dependencies to the following gems :
- httparty

## Installation

Add this line to your application's Gemfile :

```ruby
# Gemfile
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

cb = Cutter::CircuitBreaker.new(maximum_failure_limit: maximum_failure_limit, waiting_time: waiting_time)

response = cb.run do
  # call api third party here (must use httparty gem)
end
```

description of parameters:
- maximum_failure_limit = is the maximum failure limit when the state is closed. If the failure exceeds the maximum_failure_limit then the state will change to open. Example : 5 [meaning 5 times failed] ( default value is 3 ).
- waiting_time = is the waiting time when the state is open, if it exceeds this waiting time then the state will change to half open. Example : 3 [This means the waiting time from state open to half open is 5 seconds] ( default value is 5 ).

For more details, you can see the following example : [example/test.rb](https://github.com/solehudinmq/cutter/blob/development/example/test.rb).

## Example Implementation in Your Application

For examples of applications that use this gem, you can see them here : [example](https://github.com/solehudinmq/cutter/tree/development/example).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/cutter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
