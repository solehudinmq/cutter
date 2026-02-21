require 'cutter'

require_relative 'models/product'

Product.delete_all

puts "======================== STARTED [ case of targeted API performance in good condition ] ========================"
cb = ::Cutter::CircuitBreaker.new(strategy: :sync, threshold: 2, timeout: 1)

5.times do |i|
  id = i + 1
  begin
    result = cb.perform(url: "https://dummyjson.com/products/#{id}", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 5)
    puts "Request #{i+1} successful, with status code #{result.code}."
    
    payload = JSON.parse(result.body)
    product = Product.new(title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"])
    if product.save
      puts "Product with id #{product.id} successfully created"
    else
      puts "Product with request #{i+1} failed to created"
    end
  rescue => e
    puts "Request #{i+1} failed, with message #{e.message}."
  end

  sleep 1
end

puts "\n"
puts "============= [ all product data ] ================="
puts "#{Product.all.to_a}"
puts "============= [ all product data ] ================="
puts "\n"

puts "======================== ENDED [ case of targeted API performance in good condition ] ========================"
puts "\n"

Product.delete_all

puts "======================== STARTED [ case of targeted API performance in problematic conditions ] ========================"
cb = ::Cutter::CircuitBreaker.new(strategy: :sync, threshold: 2, timeout: 1)

7.times do |i|
  id = i + 1
  begin
    delay_time = 5000
    delay_time = 2000 if i > 3

    result = cb.perform(url: "https://dummyjson.com/products/#{id}/?delay=#{delay_time}", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3)
    puts "Request #{i+1} successful, with status code #{result.code}"

    payload = JSON.parse(result.body)
    product = Product.new(title: payload["title"], description: payload["description"], category: payload["category"], price: payload["price"])
    if product.save
      puts "Product with id #{product.id} successfully created"
    else
      puts "Product with request #{i+1} failed to created"
    end
  rescue => e
    puts "Request #{i+1} failed, with message #{e.message}"
  end
  sleep 1
end

puts "\n"
puts "============= [ all product data ] ================="
puts "#{Product.all.to_a}"
puts "============= [ all product data ] ================="
puts "\n"

puts "======================== ENDED [ case of targeted API performance in problematic conditions ] ========================"
puts "\n"