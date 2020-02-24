require 'rails_helper'

RSpec.describe Api::V1::TransformController do
  let(:image_file) { File.open('spec/fixtures/ruby.png') }
  let(:image_uuid) { UUID.generate }
  let(:image_url) do
    Rails.configuration.services[:resources_uri] +
      "/api/v1/resources/download/#{image_uuid}"
  end


  describe 'GET /api/v1/transform/rotate/:id', type: :request do
    context 'when the uuid does not exist' do
      before(:each) do
        given_stubbed_resource_image_as_not_found(url: image_url)
      end

      it 'returns 404 Not Found with and error message' do
        get api_v1_transform_rotate_path(image_uuid), as: :json

        expect(response).to have_http_status(:not_found)
        expect(json_response).to eq('message' => 'Not Found')
      end
    end

    context 'when the remote store service is down' do
      before(:each) do
        given_stubbed_request_to_conn_refused(url: image_url)
      end

      it 'returns 404 Not Found with and error message' do
        get api_v1_transform_rotate_path(image_uuid), as: :json

        expect(response).to have_http_status(:not_found)
        expect(json_response).to eq('message' => 'Not Found')
      end
    end

    context 'with invalid params' do
      before(:each) do
        given_stubbed_resource_image_request(url: image_url, file: image_file)
      end

      it 'returns 400 Bad Request with and error message' do
        get api_v1_transform_rotate_path(image_uuid), as: :json

        expect(response).to have_http_status(:bad_request)
        expect(json_response).to eq(
          'message' => 'param is missing or the value is empty: degrees'
        )
      end
    end

    context 'with valid degrees param' do
      let(:degrees) { -90 }
      let(:image_data) { File.read('spec/fixtures/ruby.png') }
      let(:rotated_image_blob) do
        Transformations::Rotator.rotate(image_uuid, image_data, degrees)
      end

      before(:each) do
        given_stubbed_resource_image_request(url: image_url, file: image_file)
      end

      context 'as JSON format' do
        it 'returns 200 OK with a JSON payload containing the rotated image' do
          get api_v1_transform_rotate_path(image_uuid, degrees: degrees),
              as: :json

          expect(response).to have_http_status(:ok)
          data = json_response['data']
          expect(data['contentType']).to be_present
          expect(data['imageFilename']).to be_present

          response_img = MiniMagick::Image.read(Base64.decode64(data['imageData']))
          expected_img = MiniMagick::Image.read(rotated_image_blob)
          expect(response_img).to eq expected_img
        end
      end

      context 'as HTML format' do
        it 'returns 200 OK and send the image BLOB back to the user' do
          get api_v1_transform_rotate_path(image_uuid, degrees: degrees),
              as: :html

          expect(response).to have_http_status(:ok)

          response_img = MiniMagick::Image.read(response.body)
          expected_img = MiniMagick::Image.read(rotated_image_blob)
          expect(response_img).to eq expected_img
        end
      end
    end
  end
end
