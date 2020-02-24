require 'rails_helper'

RSpec.describe Resources::Adapters::Http do
  let(:image_file) { File.open('spec/fixtures/ruby.png') }
  let(:image_uuid) { UUID.generate }
  let(:image_url) do
    Rails.configuration.services[:resources_uri] +
      "/api/v1/resources/download/#{image_uuid}"
  end

  context 'when the remote service is down' do
    it 'raises an custom error' do
      given_stubbed_request_to_conn_refused(url: image_url)

      expect do
        service = Resources::Adapters::Http.new
        service.download(image_uuid)
      end.to raise_error(Resources::Errors::ServiceUnavailableError)
    end
  end

  context 'when remote service is up' do
    it 'dowload the resource image if exists' do
      given_stubbed_resource_image_request(url: image_url, file: image_file)

      service  = Resources::Adapters::Http.new
      response = service.download(image_uuid)

      expect(response).to be_ok
      data = response.parsed_response['data']
      expect(data['attributes']['contentType']).to be_present
      expect(data['attributes']['imageData']).to be_present
    end
  end
end
