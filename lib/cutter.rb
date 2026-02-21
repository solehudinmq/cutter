# frozen_string_literal: true

require_relative "cutter/strategy"
require_relative "cutter/version"
require_relative "cutter/utils/url_validator"

module Cutter
  class CircuitBreaker
    include ::Cutter::Strategy
    include ::Cutter::UrlValidator

    HTTP_METHODS = [:GET, :POST, :PUT, :PATCH, :DELETE].freeze

    def initialize(strategy: :sync, threshold: 3, timeout: 5)
      @strategy = init_strategy(strategy: strategy, threshold: threshold, timeout: timeout)
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
