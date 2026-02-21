require_relative "strategies/circuit_breaker"

module Cutter
  module Strategy
    STRATEGIES = [:sync, :async].freeze

    def init_strategy(strategy: :sync, threshold: 3, timeout: 5)
      raise ArgumentError, "Strategy #{strategy} is not recognized." unless STRATEGIES.include?(strategy)

      case strategy
      when :sync
        ::Cutter::Sync::CircuitBreaker.new(threshold: threshold, timeout: timeout)
      when :async
      else
        raise ArgumentError, "Strategy #{strategy} unknown."
      end
    end
  end
end