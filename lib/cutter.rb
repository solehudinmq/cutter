# frozen_string_literal: true

require_relative "cutter/version"
require_relative "cutter/utils/url_validator"
require_relative "cutter/circuit_breaker_strategy.rb"

module Cutter
  class CircuitBreaker
    include ::Cutter::UrlValidator

    HTTP_METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE].freeze

    def initialize(threshold: 3, timeout: 5)
      @strategy = ::Cutter::CircuitBreakerStrategy.new(threshold: threshold, timeout: timeout)
    end

    def perform(url:, http_method: :GET, **options)
      raise ArgumentError, "Url #{url} is not valid." unless valid_url?(url)
      raise ArgumentError, "Http method #{http_method} is not recognized." unless HTTP_METHODS.include?(http_method)

      headers, body, timeout = fetch_request(http_method: http_method, options: options)

      @strategy.perform(url: url, http_method: http_method, headers: headers, body: body, timeout: timeout)
    end

    private
      def fetch_request(http_method:, options:)
        headers = options[:headers] || {}
        body = options[:body] || {}
        timeout = (options[:timeout] || 10).to_i

        raise ArgumentError, "Key parameter with 'body' name is mandatory." if [:POST, :PUT, :PATCH].include?(http_method) && body.empty?

        [ headers, body, timeout ]
      end
  end
end
