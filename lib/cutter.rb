# frozen_string_literal: true

require_relative "cutter/version"
require 'httparty'

module Cutter
  class ResponseFailed < StandardError; end
  
  class CircuitBreaker
    attr_reader :state

    # maximum_failure_limit = is the maximum failure limit when the state is closed. If the failure exceeds the maximum_failure_limit then the state will change to open. Example : 3 (meaning 3 times failed).
    # waiting_time = is the waiting time when the state is open, if it exceeds this waiting time then the state will change to half open. Example : 30 (This means the waiting time from state open to half open is 30 seconds).
    def initialize(maximum_failure_limit:, waiting_time:)
      @maximum_failure_limit = maximum_failure_limit.to_i
      @waiting_time = waiting_time.to_i

      raise "The maximum_failure_limit or waiting_time value parameters cannot be empty." if (@maximum_failure_limit < 1 || @waiting_time < 1)

      @state = :closed # The default state is closed.
      @failure_count = 0 # number of failure counters.
      @last_failure_time = nil # last recorded failure time.
      @mutex = Mutex.new # Untuk thread safety
    end

    def run
      # thread is locked
      @mutex.synchronize do
        transition_to_half_open

        # request is rejected if the state is open.
        raise "Circuit breaker is open, request is rejected." if @state == :open

        begin
          result = yield # response from the api call in the code block.
          
          unless result.success? 
            raise ResponseFailed, "Failure occurred, with status code: #{result.code}" 
          end
          
          success
          
          true
        rescue ResponseFailed => e
          failure

          false
        end
      end
    end

    private
      def transition_to_half_open
        # state open and the wait time has passed.
        if @state == :open && (Time.now - @last_failure_time) > @waiting_time
          @state = :half_open # The state changes from open to half open.
        end
      end

      # update state becomes open.
      def open!
        @state = :open
        @last_failure_time = Time.now
      end

      def failure
        if @state == :half_open
          open!

          return
        end

        @failure_count += 1 # the number of failures increases.

        # the number of failures has exceeded the maximum failure limit.
        if @failure_count >= @maximum_failure_limit
          open!
        end
      end

      def success
        if @state == :half_open
          @state = :closed
        end

        @failure_count = 0 # reset number of failures.
      end
  end
end
