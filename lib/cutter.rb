# frozen_string_literal: true

require_relative "cutter/version"
require_relative "cutter/utils/url_validator"
require_relative "cutter/circuit_breaker_strategy.rb"

module Cutter
  class CircuitBreaker
    include ::Cutter::UrlValidator

    HTTP_METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE].freeze

    # method description : circuit breaker initialization.
    # parameters :
    # - failure_threshold : maximum allowable failure, for example : 3.
    # - waiting_time : waiting time for state open to become state half open, for example : 5.
    def initialize(failure_threshold: 3, waiting_time: 5)
      @strategy = ::Cutter::CircuitBreakerStrategy.new(failure_threshold: failure_threshold, waiting_time: waiting_time)
    end

    # method description : call another api with a circuit breaker mechanism.
    # parameters :
    # - url : destination api url, for example : 'https://dummyjson.com/products/1'.
    # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
    # - **options : other additional parameters to call the destination api, for example : { headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 }.
    def perform(url:, http_method: :GET, **options)
      raise ArgumentError, "Url #{url} is not valid." unless valid_url?(url)
      raise ArgumentError, "Http method #{http_method} is not recognized." unless HTTP_METHODS.include?(http_method)

      headers, body, timeout = fetch_request(http_method: http_method, options: options)

      @strategy.perform(url: url, http_method: http_method, headers: headers, body: body, timeout: timeout)
    end

    # method description : get the latest status.
    def current_state
      @strategy.state
    end

    private
      # method description : take data from options parameter.
      # parameters :
      # - http_method : the type of http method used to call the target api, for example : :GET / :POST / :PUT / :PATCH / :DELETE.
      # - options : other additional parameters to call the destination api, for example : { headers: { 'Content-Type': 'application/json' }, body: { title: "Produk Dummy Title 1", description: "Produk Dummy Description 1" }, timeout: 5 }.
      def fetch_request(http_method:, options:)
        headers = options[:headers] || {}
        body = options[:body] || {}
        timeout = (options[:timeout] || 10).to_i

        raise ArgumentError, "Key parameter with 'body' name is mandatory." if [:POST, :PUT, :PATCH].include?(http_method) && body.empty?

        [ headers, body, timeout ]
      end
  end
end
