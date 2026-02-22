# frozen_string_literal: true

RSpec.describe Cutter::CircuitBreaker do
  it "has a version number" do
    expect(Cutter::VERSION).not_to be nil
  end

  context "method :GET" do
    it "return the final state to :closed" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}/?delay=2000", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :closed
    end

    it "return the final state to :open" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}/?delay=5000", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :open
    end
  end

  context "method :POST" do
    it "return the final state to :closed" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/add?delay=2000", http_method: :POST, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id}", description: "Produk Dummy Description #{id}", category: "dummy #{id}", price: rand(1.0..100.0).round(2) }, timeout: 3)
          expect(result.code).to be(201)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :closed
    end

    it "return the final state to :open" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/add?delay=5000", http_method: :POST, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id}", description: "Produk Dummy Description #{id}", category: "dummy #{id}", price: rand(1.0..100.0).round(2) }, timeout: 3)
          expect(result.code).to be(201)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :open
    end
  end

  context "method :PUT" do
    it "return the final state to :closed" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=2000", http_method: :PUT, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id} PUT", description: "Produk Dummy Description #{id} PUT", category: "dummy #{id} PUT", price: rand(1.0..100.0).round(2) }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :closed
    end

    it "return the final state to :open" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=5000", http_method: :PUT, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id} PUT", description: "Produk Dummy Description #{id} PUT", category: "dummy #{id} PUT", price: rand(1.0..100.0).round(2) }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :open
    end
  end

  context "method :PATCH" do
    it "return the final state to :closed" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=2000", http_method: :PATCH, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id} PATCH" }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :closed
    end

    it "return the final state to :open" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=5000", http_method: :PATCH, headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title #{id} PATCH" }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :open
    end
  end

  context "method :DELETE" do
    it "return the final state to :closed" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=2000", http_method: :DELETE, headers: { 'Content-Type': 'application/json' }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :closed
    end

    it "return the final state to :open" do
      cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
      
      expect(cb.current_state).to be :closed

      3.times do |i|
        id = i + 1
        begin
          result = cb.perform(url: "https://dummyjson.com/products/#{id}?delay=5000", http_method: :DELETE, headers: { 'Content-Type': 'application/json' }, timeout: 3)
          expect(result.code).to be(200)
        rescue => e
          puts "Request #{id} failed, with message #{e.message}"
        end

        sleep 1
      end

      expect(cb.current_state).to be :open
    end
  end

  it "return failed due to invalid url" do
    cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
    
    expect { cb.perform(url: "123", http_method: :GET, headers: { 'Content-Type': 'application/json' }, timeout: 3) }.to raise_error(ArgumentError, 'Url 123 is not valid.')
  end

  it "return failed because http_method is invalid" do
    cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
    
    expect { cb.perform(url: "https://dummyjson.com/products/1/?delay=2000", http_method: :ABC, headers: { 'Content-Type': 'application/json' }, timeout: 3) }.to raise_error(ArgumentError, 'Http method ABC is not recognized.')
  end

  it "return failed because http method :POST but body is invalid" do
    cb = ::Cutter::CircuitBreaker.new(failure_threshold: 2, waiting_time: 1)
    
    expect { cb.perform(url: "https://dummyjson.com/products/add?delay=2000", http_method: :POST, headers: { 'Content-Type': 'application/json' }, timeout: 3) }.to raise_error(ArgumentError, "Key parameter with 'body' name is mandatory.")
  end
end
