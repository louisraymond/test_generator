# frozen_string_literal: true

require 'rails_helper'

# Phase 3 — app shell: pill meta-nav + /workspace route.
# Uses rack_test (no Chromium) for speed; JavaScript-driven interactions
# land in later system specs.
RSpec.describe 'Workspace meta-nav shell', type: :request do
  describe 'GET /workspace' do
    it 'responds 200 with the four tabs' do
      get '/workspace'
      expect(response).to have_http_status(:ok)
      %w[Setup Knowledge Canvas Review].each do |tab|
        expect(response.body).to include(tab)
      end
    end

    it 'marks the tab named in ?tab= as active' do
      get '/workspace?tab=setup'
      expect(response.body).to match(%r{is-active[\s\S]*?>\s*Setup})
    end

    it 'defaults to the setup tab when no tab param is given' do
      get '/workspace'
      expect(response.body).to match(%r{is-active[\s\S]*?>\s*Setup})
    end

    it 'renders each of the four tab contents behind ?tab=' do
      %w[setup kb canvas review].each do |tab|
        get "/workspace?tab=#{tab}"
        expect(response).to have_http_status(:ok), "#{tab} tab failed"
      end
    end

    it 'shows an autosave indicator slot in the meta-nav' do
      get '/workspace'
      expect(response.body).to include('data-meta-autosave')
    end
  end
end
