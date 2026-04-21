# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API OpenAPI docs endpoint', type: :request do
  # Plain RSpec (not rswag) — the docs endpoint serves the OpenAPI spec
  # itself, so we don't want to self-document it inside the generated spec.

  describe 'GET /api/openapi.yaml' do
    it 'serves the canonical OpenAPI spec as YAML' do
      get '/api/openapi.yaml'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/yaml')
      expect(response.body).to include('openapi: 3.0.3')
      expect(response.body).to include('test_generator API')
    end

    it 'sets a public cache header' do
      get '/api/openapi.yaml'
      expect(response.headers['Cache-Control']).to include('public')
      expect(response.headers['Cache-Control']).to include('max-age=300')
    end
  end

  describe 'GET /api/openapi.yml' do
    it 'also serves YAML under the .yml extension' do
      get '/api/openapi.yml'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/yaml')
      expect(response.body).to include('openapi: 3.0.3')
    end
  end

  describe 'GET /api/openapi (no extension)' do
    it 'defaults to YAML' do
      get '/api/openapi'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/yaml')
    end
  end

  describe 'GET /api/openapi.json' do
    it 'serves the spec as JSON' do
      get '/api/openapi.json'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/json')
      parsed = JSON.parse(response.body)
      expect(parsed['openapi']).to eq('3.0.3')
      expect(parsed['info']['title']).to eq('test_generator API')
    end
  end

end
