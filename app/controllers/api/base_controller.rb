module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :ensure_json

    rescue_from ActionDispatch::Http::Parameters::ParseError do |e|
      render json: { error: "Invalid JSON: #{e.message}" }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    private

    def ensure_json
      request.format = :json
    end
  end
end
