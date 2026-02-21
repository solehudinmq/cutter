require 'httparty'
require 'json'
require_relative '../base/abstract_strategy'
require_relative '../utils/logging'

module Cutter
  module Sync
    class CircuitBreaker < ::Cutter::AbstractStrategy
      include ::Cutter::Logging

      def initialize(threshold: 3, timeout: 5)
        @threshold = threshold
        @timeout = timeout

        @failure_count = 0
        @last_failure_time = nil
        @state = :closed
        @mutex = Mutex.new  
      end

      def perform(url:, http_method:, headers: {}, body: {}, timeout: 10)
        logger.info("Current circuit state is #{@state}.")

        @mutex.synchronize do
          check_state

          case @state
          when :open
            raise "Circuit is OPEN, request rejected."
          when :half_open, :closed
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
        def check_state
          if @state == :open && Time.now > @last_failure_time + @timeout
            @state = :half_open
            logger.info("Circuit moved to :half_open. Testing connection...")
          end
        end

        def handle_failure
          @failure_count += 1
          @last_failure_time = Time.now
          
          if @failure_count >= @threshold
            @state = :open
            logger.warn("Circuit is now :open due to multiple failures.")
          end
        end

        def reset_circuit
          @failure_count = 0
          @state = :closed
          @last_failure_time = nil
        end

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
end