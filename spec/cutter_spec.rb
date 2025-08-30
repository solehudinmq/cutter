# frozen_string_literal: true

RSpec.describe Cutter::CircuitBreaker do
  it "has a version number" do
    expect(Cutter::VERSION).not_to be nil
  end

  def success_simulation_with_timeout(index)
    if index == 1
      raise("Timeout!")
    end

    "Data received successfully!"
  end

  def success_simulation
    "Data received successfully!"
  end

  def timeout_simulation
    raise("Timeout!")
  end

  it "state does not change" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    1.times do |i|
      begin
        response = cb.run { success_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end
    
    expect(cb.state).to be :closed
  end

  it "state does not change because total_failure is 1" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    3.times do |i|
      begin
        response = cb.run { success_simulation_with_timeout(i) }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end
    
    expect(cb.state).to be :closed
  end

  it "state closed changes to open" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    4.times do |i|
      begin
        response = cb.run { timeout_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
        expect(e.message).to be 'Circuit breaker is open, request is rejected.' if i == 3
      end
    end
    
    expect(cb.state).to be :open
  end

  it "state open changes to closed" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    4.times do |i|
      begin
        response = cb.run { timeout_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
        expect(e.message).to be 'Circuit breaker is open, request is rejected.' if i == 3
      end
    end
    
    expect(cb.state).to be :open

    sleep 4 # update state to half open
    
    1.times do |i|
      begin
        response = cb.run { success_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end

    expect(cb.state).to be :closed
  end

  it "state half open changes to open" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    4.times do |i|
      begin
        response = cb.run { timeout_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
        expect(e.message).to be 'Circuit breaker is open, request is rejected.' if i == 3
      end
    end
    
    expect(cb.state).to be :open

    sleep 4 # update state to half open
    
    1.times do |i|
      begin
        response = cb.run { timeout_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end

    expect(cb.state).to be :open
  end
end
