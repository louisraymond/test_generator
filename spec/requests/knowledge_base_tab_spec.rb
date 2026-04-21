# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workspace knowledge base tab', type: :request do
  let!(:topic_a) { create(:topic, name: 'Calculus') }
  let!(:topic_b) { create(:topic, name: 'Probability') }
  let!(:module_a1) { create(:topic_module, topic: topic_a, name: 'Derivatives', position: 0) }

  describe 'GET /workspace?tab=kb' do
    it 'renders a two-pane layout with topic tree and resource list' do
      get '/workspace?tab=kb'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('kb__tree')
      expect(response.body).to include('kb__resources')
    end

    it 'lists topics with count badges' do
      create(:question, topic: topic_a)
      get '/workspace?tab=kb'
      expect(response.body).to include('Calculus')
      expect(response.body).to include('Probability')
      expect(response.body).to match(/Calculus.*1/m) # topic_a has 1 question
    end

    it 'shows child topic_modules under each topic' do
      get '/workspace?tab=kb'
      expect(response.body).to include('Derivatives')
    end

    it 'has a dashed-border upload affordance' do
      get '/workspace?tab=kb'
      expect(response.body).to match(/kb-upload|drop-zone/)
    end
  end
end
