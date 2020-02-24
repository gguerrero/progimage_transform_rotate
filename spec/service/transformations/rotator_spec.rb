require 'rails_helper'

RSpec.describe Transformations::Rotator do
  let(:image_uuid) { UUID.generate }
  let(:image_data) { File.read('spec/fixtures/ruby.png') }
  let(:degrees) { -90 }

  describe '#rotator' do
    it 'return the BLOB of a given image data for the given degrees' do
      expected_image = MiniMagick::Image.read(image_data)
      expected_blob = expected_image.rotate(degrees).to_blob

      expect(
        Transformations::Rotator.rotate(image_uuid, image_data, degrees)
      ).to eq expected_blob
    end
  end
end
