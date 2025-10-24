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