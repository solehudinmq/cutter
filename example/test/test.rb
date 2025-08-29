require 'cutter'

# 3rdparty api call simulation.
class ThirdPartyService
    # method random simulation response from 3rd party
    def self.call
        # success/failure response simulation.
        rand > 0.4 ? "Data received successfully!" : raise("Timeout!")
    end
end

# Initialize circuit breaker.
cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 5)
5.times do |i|
    puts "==> Try to-#{i + 1}"
    begin
        response = cb.run do
            ThirdPartyService.call
        end
        
        puts "Respons: '#{response}'"
    rescue => e
        puts "Error: #{e.message}"
    end
    puts "\n"
    sleep(1) # Wait 1 second between attempts.
end

# how to run : 
# note : make sure the gem cutter folder is aligned with your application folder. 
# 1. bundle install
# 2. bundle exec ruby test.rb