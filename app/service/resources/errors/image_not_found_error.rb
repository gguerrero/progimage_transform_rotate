module Resources
  module Errors
    class ImageNotFoundError < StandardError
      def initialize(msg = 'Image not found for resource')
        super
      end
    end
  end
end
