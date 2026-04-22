require 'rails_helper'

RSpec.describe 'Question paper-editor toggles', type: :request do
  let(:topic) { create(:topic) }

  describe 'POST /questions/:id/toggle_eliminated' do
    it 'flips the eliminated flag on an MCQ option' do
      q = Question.create!(
        topic: topic, question_type: 'multiple_choice',
        content: 'q', answer: 'a', points: 1,
        options: [{ 'text' => 'a', 'correct' => true }, { 'text' => 'b' }]
      )
      post "/questions/#{q.id}/toggle_eliminated", params: { index: 1 }
      expect(response).to have_http_status(:ok)
      expect(q.reload.options[1]['eliminated']).to be true
      post "/questions/#{q.id}/toggle_eliminated", params: { index: 1 }
      expect(q.reload.options[1]['eliminated']).to be false
    end

    it 'returns 422 for non-MCQ types' do
      q = Question.create!(topic: topic, question_type: 'written',
                           content: 'x', answer: 'y', points: 1)
      post "/questions/#{q.id}/toggle_eliminated", params: { index: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /questions/:id/options_patch' do
    it 'merges a partial options hash into the existing jsonb' do
      q = Question.create!(
        topic: topic, question_type: 'matching',
        content: 'q', answer: 'a', points: 1,
        options: { 'left' => %w[a b], 'right' => %w[1 2] }
      )
      patch "/questions/#{q.id}/options_patch",
            params: { options: { seed: 42 } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
      merged = q.reload.options
      expect(merged['left']).to eq(%w[a b])
      expect(merged['right']).to eq(%w[1 2])
      expect(merged['seed'].to_i).to eq(42)
    end
  end
end
