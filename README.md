# Cutter

Cutter is a Ruby library that implements the circuit breaker design pattern, so your application will be more stable even if your 3rd party application is having problems.

With the Cutter library, your Ruby application will remain stable even if a connected third-party application experiences problems. This library implements the circuit breaker design pattern; in other words, it protects your application from system failures caused by external factors.

## High Flow
potential problems when 3rdparty applications experience problems : 
![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-problem.jpg)

circuit breaker solution to prevent system failure due to problematic 3rdparty applications :
![Logo Ruby](https://github.com/solehudinmq/cutter/blob/development/high_flow/cutter-solution.jpg)

## Installation

The minimum version of Ruby that must be installed is 3.0. Only supports using the 'httpparty' gem to call the API.

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

cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 5)

response = cb.run do
    # call api third party here (must use httparty gem)
    HTTParty.post(url, 
      body: body,
      headers: headers,
      timeout: 3
    )
end
```

description of parameters:
- maximum_failure_limit = is the maximum failure limit when the state is closed. If the failure exceeds the maximum_failure_limit then the state will change to open. Example : 3 (meaning 3 times failed).
- waiting_time = is the waiting time when the state is open, if it exceeds this waiting time then the state will change to half open. Example : 5 (This means the waiting time from state open to half open is 5 seconds).

The following is an example of use in your application : 
```ruby
# Gemfile
# frozen_string_literal: true

source "https://rubygems.org"

gem "cutter", git: "git@github.com:solehudinmq/cutter.git", branch: "main"
gem "byebug"
gem "sinatra"
gem "activerecord"
gem "sqlite3"
gem "httparty"
gem "rackup", "~> 2.2"
gem "puma", "~> 7.1"
```

```ruby
# post.rb

require 'sinatra'
require 'active_record'
require 'byebug'

# Configure database connections
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

# Create a db directory if it doesn't exist yet
Dir.mkdir('db') unless File.directory?('db')

# Model
class Post < ActiveRecord::Base
end

# Migration to create posts table
ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.table_exists?(:posts)
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.timestamps
    end
  end
end
```

```ruby
# app.rb

require 'sinatra'
require 'json'
require 'byebug'
require_relative 'post'

# create data post
post '/posts' do
  begin
    request_body = JSON.parse(request.body.read)
    post = Post.create(title: request_body["title"], content: request_body["content"])

    content_type :json
    status 201
    return { post_id: post.id, message: 'success' }.to_json
  rescue => e
    content_type :json
    status 500
    return { error: e.message }.to_json
  end
end

# server errors simulations
post '/simulation_server_problems' do
  status 503

  content_type :json
  return { error: 'The server is having problems.' }.to_json
end

# open terminal
# cd your_project
# bundle install
# bundle exec ruby app.rb
# 1. success scenario
# curl --location 'http://localhost:4567/posts' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content 1"
# }'
# 2. failed scenario
# curl --location 'http://localhost:4567/simulation_server_problems' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content 1"
# }'
```

```ruby
# third_party_service.rb

require 'httparty'

# 3rdparty api call simulation.
class ThirdPartyService
  # method random simulation response from 3rd party
  def self.call(url, body, headers)
    response = HTTParty.post(url, 
      body: body,
      headers: headers,
      timeout: 3
    )
    
    response
  end
end
```

```ruby
# test.rb

require 'cutter'
require 'json'
require 'byebug'

require_relative 'third_party_service'

puts "================ success simulation ========================="
cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
5.times do |i|
  begin
    puts "==> Try to-#{i + 1}"

    response = cb.run do
      ThirdPartyService.call("http://localhost:4567/posts", 
        { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
        { 'Content-Type' => 'application/json' })
    end
    
    puts "Response: '#{response}'"
  rescue => e
    puts "Error Response : #{e.message}"

    sleep 2
  end
end

sleep 2

puts "================ failed simulation ========================="
cb2 = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
5.times do |i|
  begin
    puts "==> Try to-#{i + 1}"
    
    response2 = cb2.run do
      ThirdPartyService.call("http://localhost:4567/simulation_server_problems", 
        { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
        { 'Content-Type' => 'application/json' })
    end
    
    puts "Response: '#{response2}'"
  rescue => e
    puts "Error Response : #{e.message}"

    sleep 2
  end
end

# how to run : 
# note : run 'bundle exec ruby app.rb' is required
# 1. bundle install
# 2. bundle exec ruby test.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/cutter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
