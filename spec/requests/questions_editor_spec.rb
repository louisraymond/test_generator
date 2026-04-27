require 'rails_helper'

RSpec.describe 'Question editor save endpoints', type: :request do
  let!(:topic) { create(:topic) }

  describe 'PATCH /questions/:id' do
    let!(:question) { create(:question, topic: topic, content: 'old', answer: 'old answer') }

    it 'updates content from a JSON PATCH' do
      patch question_path(question),
            params: { question: { content: '## new' } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:found).or have_http_status(:ok)
      expect(question.reload.content).to eq('## new')
    end

    it 'updates answer from a JSON PATCH' do
      patch question_path(question),
            params: { question: { answer: 'new answer' } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(question.reload.answer).to eq('new answer')
    end
  end
end
