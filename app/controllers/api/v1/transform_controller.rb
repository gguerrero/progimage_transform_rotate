module Api::V1
  class TranformController < ApplicationController
    before_action :resource, only: %i[rotate]

    def rotate
      variant = Tranformations::Rotator.rotate(resource)

      render json: Api::V1::TranformationSerializer.new(variant),
             status: :created
    end

    private

    def rotate_params
      params.permit(:degrees)
    end

    def resource
      @resource ||= Resources::Images.retrieve(params[:id])
    rescue Resources::Errors::ImageNotFoundError
      render json: { message: 'Not Found' }, status: :not_found
    end
  end
end
