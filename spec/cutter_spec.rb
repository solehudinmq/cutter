# frozen_string_literal: true

require 'byebug'

RSpec.describe Cutter::CircuitBreaker do
  it "has a version number" do
    expect(Cutter::VERSION).not_to be nil
  end

  before(:all) do
    @cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 5)
  end

  def closed_state_simulation(index)
    if index == 1
      raise("Timeout!")
    end

    "Data received successfully!"
  end

  def open_state_simulation
    raise("Timeout!")
  end

  def half_open_simulation
    "Data received successfully!"
  end

  it "state does not change" do
    3.times do |i|
      begin
        response = @cb.run { closed_state_simulation(i) }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end
    
    expect(@cb.state).to be :closed
  end

  it "state closed changes to open" do
    4.times do |i|
      begin
        response = @cb.run { open_state_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end
    
    expect(@cb.state).to be :open
  end

  it "request rejected because state is open" do
    1.times do |i|
      begin
        response = @cb.run { closed_state_simulation(i) }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
        expect(e.message).to be "Circuit breaker is open, request is rejected."
      end
    end
  end

  it "state open changes to closed" do
    sleep 6
    1.times do |i|
      begin
        response = @cb.run { half_open_simulation }
        puts "Success: #{response}"
      rescue => e
        puts "Error: #{e.message}"
      end
    end
    
    expect(@cb.state).to be :closed
  end
end
