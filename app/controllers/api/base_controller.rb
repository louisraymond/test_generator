module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :ensure_json

    private

    def ensure_json
      request.format = :json
    end
  end
end
