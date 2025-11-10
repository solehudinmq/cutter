require 'cutter'
require 'json'
require 'byebug'
require 'httparty'

puts "================ success simulation ========================="
cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
5.times do |i|
  begin
    puts "==> Try to-#{i + 1}"

    response = cb.run do
      HTTParty.post("http://localhost:4567/posts", 
        body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
        headers: { 'Content-Type' => 'application/json' },
        timeout: 3
      )
    end
    
    puts "Response : #{response}"
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
      HTTParty.post("http://localhost:4567/simulation_server_problems", 
        body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json,
        headers: { 'Content-Type' => 'application/json' },
        timeout: 3
      )
    end
    
    puts "Response : #{response2}"
  rescue => e
    puts "Error Response : #{e.message}"

    sleep 2
  end
end

# how to run : 
# note : run 'bundle exec ruby app.rb' is required
# 1. bundle install
# 2. bundle exec ruby test.rb