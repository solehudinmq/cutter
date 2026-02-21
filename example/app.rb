require 'cutter'

puts "======="
puts "1. GET"
puts "======="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}/?delay=#{delay_time}", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3)
    puts "Request #{id} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{id} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data that was successfully obtained ] ================="
puts "#{datas}"
puts "\n"

puts "======="
puts "2. POST"
puts "======="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/add?delay=#{delay_time}", http_method: :POST, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id}", description: "Produk Dummy Description #{id}", category: "dummy #{id}", price: rand(1.0..100.0).round(2) }, timeout: 3)
    puts "Request #{id} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{id} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data after successfully creating data ] ================="
puts "#{datas}"
puts "\n"

puts "======="
puts "3. PUT"
puts "======="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=#{delay_time}", http_method: :PUT, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title PUT #{id}", description: "Produk Dummy Description PUT #{id}", category: "dummy PUT #{id}", price: rand(1.0..100.0).round(2) }, timeout: 3)
    puts "Request #{id} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{id} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data after successfully updating all data ] ================="
puts "#{datas}"
puts "\n"

puts "========"
puts "4. PATCH"
puts "========"

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=#{delay_time}", http_method: :PATCH, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title PATCH #{id}" }, timeout: 3)
    puts "Request #{id} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"] }
  rescue => e
    puts "Request #{id} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data after successfully updating one of the data fields ] ================="
puts "#{datas}"
puts "\n"

puts "========="
puts "5. DELETE"
puts "========="

cb = ::Cutter::CircuitBreaker.new(threshold: 2, timeout: 1)

datas = []
7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=#{delay_time}", http_method: :DELETE, headers: { 'Content-Type': 'application/json' }, timeout: 3)
    puts "Request #{id} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    datas << { id: payload["id"], title: payload["title"], is_deleted: payload["isDeleted"], deleted_on: payload["deletedOn"] }
  rescue => e
    puts "Request #{id} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ data after successfully deleting data ] ================="
puts "#{datas}"
puts "\n"

# run this command :
# - open terminal
# - cd example
# - bundle install
# - bundle exec ruby app.rb