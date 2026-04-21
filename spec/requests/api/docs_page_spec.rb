# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API docs page (Scalar)', type: :request do
  describe 'GET /api/docs.html' do
    it 'serves the static Scalar docs page' do
      get '/api/docs.html'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('text/html')
      # Should reference the spec URL; if someone renames the spec path we
      # catch it here.
      expect(response.body).to include('/api/openapi.yaml')
      expect(response.body).to include('@scalar/api-reference')
    end
  end

  describe 'GET /api/docs' do
    it 'redirects to the static docs page' do
      get '/api/docs'
      expect(response).to redirect_to('/api/docs.html')
    end
  end
end
