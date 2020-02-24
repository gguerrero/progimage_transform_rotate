require 'rails_helper'

RSpec.describe Api::V1::TransformationSerializer do
  let(:image_uuid) { UUID.generate }
  let(:image_data) { File.read('spec/fixtures/ruby.png') }
  let(:degrees) { -90 }
  let(:variant_blob) do
    Transformations::Rotator.rotate(image_uuid, image_data, degrees)
  end

  context 'serializing it as JSON' do
    it 'returns a hash with the expected attributes' do
      serializer = Api::V1::TransformationSerializer.new(
        variant_blob,
        'image/png',
        'ruby.png'
      )
      data = serializer.as_json[:data]

      expect(data).to eq(
        contentType: 'image/png',
        imageFilename: 'ruby.png',
        imageData: Base64.encode64(variant_blob)
      )
    end
  end
end
