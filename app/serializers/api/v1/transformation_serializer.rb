module Api::V1
  class TranformationSerializer
    include FastJsonapi::ObjectSerializer

    set_key_transform :camel_lower

    attributes :name, :description

    attribute :content_type do |object|
      "image/png"
    end

    attribute :image_filename do |object|
      "image_filename.png"
    end

    attribute :image_data do |object|
      Base64.encode64(object.data)
    end
  end
end
