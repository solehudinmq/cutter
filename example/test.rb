require 'cutter'

puts "====================================================="
puts "1. case of targeted API performance in good condition"
puts "====================================================="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
5.times do |i|
  id = i + 1
  begin
    result = cb.perform(url: "https://dummyjson.com/products/#{id}", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 5)
    puts "Request #{i+1} successful, with status code #{result.code}."
    
    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{i+1} failed, with message #{e.message}."
  end

  sleep 1
end

puts "\n"
puts "============= [ data that was successfully obtained ] ================="
puts "#{datas}"
puts "\n"

puts "============================================================="
puts "2. case of targeted API performance in problematic conditions"
puts "============================================================="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}/?delay=#{delay_time}", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3)
    puts "Request #{i+1} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{i+1} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data that was successfully obtained ] ================="
puts "#{datas}"
puts "\n"

# puts "======================== STARTED [ case of adding new data ] ========================"
# cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

