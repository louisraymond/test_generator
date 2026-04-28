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

  # Editor #11 / ticket #47 — AR is the source of truth for composite parts.
  # The two specs below assert that update_part / add_part write to
  # QuestionPart rows (not the legacy `options['parts']` jsonb). The jsonb
  # column is left intact for one deprecation cycle so a rollback is safe.
  describe 'AR-backed composite parts (Editor #11)' do
    let!(:composite) do
      q = create(:question, :composite, topic: topic, options: {})
      q.question_parts.create!(position: 1, part_type: 'written',     marks: 2, stem: 'AR Part A.')
      q.question_parts.create!(position: 2, part_type: 'calculation', marks: 3, stem: 'AR Part B.')
      q
    end

    it 'update_part writes to the QuestionPart AR row and leaves jsonb untouched' do
      original_jsonb = composite.options.deep_dup

      patch options_patch_question_path(composite),
            params: { options: { update_part: { index: 0, stem: 'new stem' } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(composite.question_parts.find_by(position: 1).reload.stem).to eq('new stem')
      # jsonb fallback should be left intact for one deprecation cycle.
      expect(composite.reload.options).to eq(original_jsonb)
    end

    it 'add_part creates a new QuestionPart AR row with sensible defaults' do
      patch options_patch_question_path(composite),
            params: { options: { add_part: { after: 0 } } }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(composite.question_parts.count).to eq(3)

      new_part = composite.question_parts.find_by(position: 2)
      expect(new_part.stem).to eq('')
      expect(new_part.part_type).to eq('written')
      expect(new_part.marks).to eq(1)

      # Original second part shifts to position 3.
      shifted = composite.question_parts.find_by(position: 3)
      expect(shifted.stem).to eq('AR Part B.')
    end
  end
end
