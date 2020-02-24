module Resources
  module Errors
    class ServiceUnavailableError < StandardError
      def initialize(msg = 'Resources store service is not available!')
        super
      end
    end
  end
end
