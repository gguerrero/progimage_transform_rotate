module Resources
  module Adapters
    class Http
      include HTTParty

      base_uri Rails.configuration.services[:resources_uri]
      headers 'Content-Type' => 'application/json'
      default_timeout 5
      format :json

      attr_reader :api_path

      def initialize(version: 'v1')
        @api_path = "/api/#{version}"
      end

      def download(uuid)
        self.class.get("#{api_path}/resources/download/#{uuid}")
      rescue Errno::ECONNREFUSED
        raise Resources::Errors::ServiceUnavailableError
      end
    end
  end
end
