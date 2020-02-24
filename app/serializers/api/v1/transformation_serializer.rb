module Api::V1
  class TransformationSerializer
    attr_reader :variant_blob, :image_type, :image_filename

    def initialize(variant_blob, image_type, image_filename)
      @variant_blob     = variant_blob
      @image_type       = image_type
      @image_filename   = image_filename
    end

    def as_json(_opts = {})
      {
        data: {
          contentType: image_type,
          imageFilename: image_filename,
          imageData: Base64.encode64(variant_blob)
        }
      }
    end
  end
end
