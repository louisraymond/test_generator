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

  describe 'PATCH /questions/:id/options_patch with update_part' do
    let!(:composite) { create(:question, :composite, topic: topic) }

    it 'updates a sub-part stem and leaves siblings untouched' do
      patch options_patch_question_path(composite),
            params: { options: { update_part: { index: 1, stem: 'Revised B.' } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      parts = composite.reload.options['parts']
      expect(parts[0]['stem']).to eq('Part A.')
      expect(parts[1]['stem']).to eq('Revised B.')
      expect(parts[1]['type']).to eq('calculation')   # other fields untouched
      expect(parts[1]['marks']).to eq(3)
    end

    it 'returns 422 when the index is out of range' do
      patch options_patch_question_path(composite),
            params: { options: { update_part: { index: 99, stem: 'x' } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 on a non-composite question' do
      written = create(:question, topic: topic)
      patch options_patch_question_path(written),
            params: { options: { update_part: { index: 0, stem: 'x' } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /questions/:id/options_patch with add_part' do
    let!(:composite) { create(:question, :composite, topic: topic) }

    it 'inserts a new part with sensible defaults at the requested position' do
      patch options_patch_question_path(composite),
            params: { options: { add_part: { after: 0 } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      parts = composite.reload.options['parts']
      expect(parts.length).to eq(3)
      expect(parts[1]).to include('stem' => '', 'type' => 'written', 'marks' => 1)
      expect(parts[0]['stem']).to eq('Part A.')           # original part 0 stays
      expect(parts[2]['stem']).to eq('Part B.')           # original part 1 shifted to 2
    end

    it 'inserts at the end when after is the last index' do
      patch options_patch_question_path(composite),
            params: { options: { add_part: { after: 1 } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(composite.reload.options['parts'].length).to eq(3)
    end

    it 'returns 422 on a non-composite question' do
      written = create(:question, topic: topic)
      patch options_patch_question_path(written),
            params: { options: { add_part: { after: 0 } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
