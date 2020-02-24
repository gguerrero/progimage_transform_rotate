require "mini_magick"

module Transformations
  class Rotator
    @expires_in = 10.minutes
    @race_condition_ttl = 10.seconds

    class << self
      attr_reader :expires_in, :race_condition_ttl

      def rotate(image_uuid, image_data, degrees)
        Rails.cache.fetch(cache_key(image_uuid, degrees),
                          expires_in: expires_in,
                          race_condition_ttl: race_condition_ttl) do
          image = MiniMagick::Image.read(image_data)
          image.rotate(degrees).to_blob
        end
      end

      private

      def cache_key(image_uuid, degrees)
        "tranformations-rotate/#{image_uuid}/#{degrees}"
      end
    end
  end
end
