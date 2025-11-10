# frozen_string_literal: true

# required : bundle exec ruby app.rb
RSpec.describe Cutter::CircuitBreaker do
  before(:all) do
    Post.delete_all
  end

  it "has a version number" do
    expect(Cutter::VERSION).not_to be nil
  end

  it "return state is still closed" do
    # with the set parameter values
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
    
    expect(cb.state).to be :closed

    1.times do |i|
      begin
        response = cb.run do
          HTTParty.post("http://localhost:4567/posts", 
            body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
            headers: { 'Content-Type' => 'application/json' },
            timeout: 3
          )
        end

        puts "Response With Parameter : '#{response}'"
      rescue => e
        puts "Error Response With Parameter : #{e.message}"

        sleep 2
      end
    end

    expect(cb.state).to be :closed

    # with default parameter values
    cb2 = Cutter::CircuitBreaker.new(maximum_failure_limit: nil, waiting_time: nil)

    1.times do |i|
      begin
        response = cb2.run do
          HTTParty.post("http://localhost:4567/posts", 
            body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
            headers: { 'Content-Type' => 'application/json' },
            timeout: 3
          )
        end

        puts "Response Without Parameter : '#{response}'"
      rescue => e
        puts "Error Response Without Parameter : #{e.message}"

        sleep 2
      end
    end

    expect(cb2.state).to be :closed
  end

  it "return state changes to open" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
    
    expect(cb.state).to be :closed

    4.times do |i|
      begin
        puts "==> Try to-#{i + 1}"
        
        response = cb.run do
          HTTParty.post("http://localhost:4567/simulation_server_problems", 
            body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
            headers: { 'Content-Type' => 'application/json' },
            timeout: 3
          )
        end
        
        puts "Response: '#{response}'"
      rescue => e
        puts "Error Response : #{e.message}"

        sleep 2
      end
    end

    expect(cb.state).to be :open
  end

  it "return state changes to closed, after the state changes to open" do
    cb = Cutter::CircuitBreaker.new(maximum_failure_limit: 3, waiting_time: 1)
    
    expect(cb.state).to be :closed

    5.times do |i|
      begin
        puts "==> Try to-#{i + 1}"
        
        if i == 4
          # state changes to closed after waiting 1 second and successfully creating a post
          response = cb.run do
            HTTParty.post("http://localhost:4567/posts", 
              body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
              headers: { 'Content-Type' => 'application/json' },
              timeout: 3
            )
          end
        else
          # state changes to open after 3x failure
          response = cb.run do
            HTTParty.post("http://localhost:4567/simulation_server_problems", 
              body: { title: "Post #{i + 1}", content: "Content #{i + 1}" }.to_json, 
              headers: { 'Content-Type' => 'application/json' },
              timeout: 3
            )
          end
        end
        
        puts "Response: '#{response}'"
      rescue => e
        puts "Error Response : #{e.message}"

        sleep 2
      end
    end

    expect(cb.state).to be :closed
  end
end
