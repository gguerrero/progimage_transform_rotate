require 'rails_helper'

RSpec.describe Resources::Adapters::Http do
  let(:image_file) { File.open('spec/fixtures/ruby.png') }
  let(:image_uuid) { UUID.generate }
  let(:image_url) do
    Rails.configuration.services[:resources_uri] +
      "/api/v1/resources/download/#{image_uuid}"
  end

  context 'downloading an image' do
    it 'raised and error if the response is not OK' do
      given_stubbed_resource_image_as_not_found(url: image_url)

      expect do
        Resources::Images.download(image_uuid)
      end.to raise_error(Resources::Errors::ImageNotFoundError)
    end

    it 'returns the data content of the dowload parsed response' do
      given_stubbed_resource_image_request(url: image_url, file: image_file)

      data = Resources::Images.download(image_uuid)
      expect(data['id']).to be_present
      expect(data['attributes']).to be_present
      expect(data['attributes']['contentType']).to be_present
      expect(data['attributes']['imageData']).to be_present
    end
  end

  context 'extracting the image data from some chunk of data' do
    before(:each) do
      given_stubbed_resource_image_request(url: image_url, file: image_file)
    end

    it 'returns only a valid BLOB byte string of the image' do
      img = Resources::Images.download(image_uuid)
      img_data = Resources::Images.image_data(img)

      expect(img_data).to be_present
      expect(img_data.size).to eq image_file.size
      expect(MiniMagick::Image.read(img_data)).to be_valid
    end
  end
end
