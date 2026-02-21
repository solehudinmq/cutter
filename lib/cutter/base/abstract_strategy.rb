module Cutter
  class AbstractStrategy
    def call(url:, http_method:, options:) raise NotImplementedError end
  end
end