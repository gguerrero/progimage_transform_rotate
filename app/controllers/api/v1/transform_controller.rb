module Api::V1
  class TransformController < ApplicationController
    before_action :image, only: %i[rotate]
    before_action :image_data, only: %i[rotate]

    def rotate
      image_uuid = image['id']
      image_type = image['attributes']['contentType']
      image_filename = image['attributes']['imageFilename']

      variant_blob = Transformations::Rotator.rotate(
        image_uuid,
        image_data,
        rotate_degrees_param
      )

      respond_to do |format|
        format.json do
          render json: Api::V1::TransformationSerializer.new(
            variant_blob,
            image_type,
            image_filename
          )
        end

        format.html do
          send_data variant_blob,
                    filename: image_filename,
                    type: image_type
        end
      end
    rescue ActionController::ParameterMissing => e
      render json: { message: e.message }, status: :bad_request
    end

    private

    def rotate_degrees_param
      params.require(:degrees)
    end

    def image
      @image ||= Resources::Images.download(params[:id])
    rescue Resources::Errors::ServiceUnavailableError,
           Resources::Errors::ImageNotFoundError
      render json: { message: 'Not Found' }, status: :not_found
    end

    def image_data
      @image_data ||= Resources::Images.image_data(image)
    end
  end
end
