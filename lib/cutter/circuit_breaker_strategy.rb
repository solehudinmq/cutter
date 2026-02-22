require 'httparty'
require 'json'
require_relative 'utils/logging'

module Cutter
  class CircuitBreakerStrategy
    include ::Cutter::Logging

    attr_reader :state

    # method description : circuit breaker initialization.
    # parameters :
    # - failure_threshold : maximum allowable failure, for example : 3.
    # - waiting_time : waiting time for state open to become state half open, for example : 5.
    def initialize(failure_threshold: 3, waiting_time: 5)
      @failure_threshold = failure_threshold
      @waiting_time = waiting_time

      @failure_count = 0
      @last_failure_time = nil
      @state = :closed
      @mutex = Mutex.new  
    end

    # method description : call another api with a circuit breaker mechanism.
    # parameters :
    # - url : destination api url, for example : 'https://dummyjson.com/products/1'.
    # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
    # - headers : request headers, for example : { 'Content-Type': 'application/json' }.
    # - body : request body, for example : { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }.
    # - timeout : maximum timeout limit in seconds when calling the target api, for example : 10.
    def perform(url:, http_method:, headers: {}, body: {}, timeout: 10)
      logger.info("Current circuit state is #{@state}.")

      @mutex.synchronize do
        check_state

        case @state
        when :open # :open state will reject request to destination api.
          raise "Circuit is OPEN, request rejected."
        when :half_open, :closed # :closed or :half_open state will allow the request to proceed to the destination api.
          begin
            result = execute(url: url, http_method: http_method, headers: headers, body: body, timeout: timeout)
            reset_circuit
            return result
          rescue StandardError => e
            handle_failure
            raise e
          end
        end
      end
    end

    private
      # method description : change the state from :open to :half_open if it has exceeded the waiting time.
      def check_state
        if @state == :open && Time.now > @last_failure_time + @waiting_time
          @state = :half_open
          logger.info("Circuit moved to :half_open. Testing connection...")
        end
      end

      # method description : change the state to :open if the number of failures is equal to the maximum failure limit when the state is :closed or 1x failure occurs when the state is :half_open.
      def handle_failure
        if @state == :half_open # when the state is :half_open and there is 1 failure, the state changes to :open.
          @state = :open
          logger.warn("Circuit is now :open, because the process fails when the state is :half_open.")
          return
        end

        @failure_count += 1
        @last_failure_time = Time.now
        
        if @failure_count >= @failure_threshold
          @state = :open
          logger.warn("Circuit is now :open due to multiple failures.")
        end
      end

      # method description : change state to :closed and reset all failure settings.
      def reset_circuit
        @failure_count = 0
        @state = :closed
        @last_failure_time = nil
      end

      # method description : call the destination api based on the selected http method.
      # parameters :
      # - url : destination api url, for example : 'https://dummyjson.com/products/1'.
      # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
      # - headers : request headers, for example : { 'Content-Type': 'application/json' }.
      # - body : request body, for example : { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }.
      # - timeout : maximum timeout limit in seconds when calling the target api, for example : 10.
      def execute(url:, http_method:, headers: {}, body: {}, timeout: 10)
        options = { timeout: timeout }
        options[:headers] = headers if !headers.empty?
        options[:body] = body.to_json if [:POST, :PUT, :PATCH].include?(http_method)
        
        case http_method
        when :GET
          HTTParty.get(url, options)
        when :POST
          HTTParty.post(url, options)
        when :PUT
          HTTParty.put(url, options)
        when :PATCH
          HTTParty.patch(url, options)
        when :DELETE
          HTTParty.delete(url, options)
        else
          raise "Failed to execute."
        end
      end
  end
end