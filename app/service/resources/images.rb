module Resources
  class Images
    @adapter = Resources::Adapters::Http.new
    @expires_in = 1.hour
    @race_condition_ttl = 10.seconds

    class << self
      attr_reader :adapter, :expires_in, :race_condition_ttl

      def download(image_uuid)
        Rails.cache.fetch(cache_key(image_uuid),
                          expires_in: expires_in,
                          race_condition_ttl: race_condition_ttl) do
          response = adapter.download(image_uuid)
          raise Errors::ImageNotFoundError unless response.ok?

          response.parsed_response['data']
        end
      end

      def image_data(data)
        Base64.decode64(data['attributes']['imageData'])
      end

      private

      def cache_key(uuid)
        "resource-image/#{uuid}"
      end
    end
  end
end
