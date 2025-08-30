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

    # response call api 1 -> success
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

    # response call api 1 -> success
    # response call api 2 -> timeout
    # response call api 3 -> success
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

    # response call api 1 -> timeout
    # response call api 2 -> timeout
    # response call api 3 -> timeout
    # response call api 4 -> timeout
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

  it "state half open changes to closed" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    # response call api 1 -> timeout
    # response call api 2 -> timeout
    # response call api 3 -> timeout
    # response call api 4 -> timeout
    # response call api 5 -> success
    5.times do |i|
      if i == 4
        sleep 4 # waiting time to change state from open to half open
      end

      begin
        response = cb.run do 
          if i == 4
            success_simulation
          else
            timeout_simulation
          end
        end

        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
        expect(e.message).to be 'Circuit breaker is open, request is rejected.' if i == 3
      end
    end
    
    expect(cb.state).to be :closed
  end

  it "state half open changes to open" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 3)

    expect(cb.state).to be :closed

    # response call api 1 -> timeout
    # response call api 2 -> timeout
    # response call api 3 -> timeout
    # response call api 4 -> timeout
    # response call api 5 -> timeout
    5.times do |i|
      if i == 4
        sleep 4 # waiting time to change state from open to half open
      end

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
end
