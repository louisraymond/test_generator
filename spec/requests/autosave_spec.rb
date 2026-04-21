# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exam autosave', type: :request do
  let(:exam) { create(:exam, title: 'Autosave target') }

  describe 'PATCH /api/exams/:id/autosave' do
    it 'updates the exam title and bumps lock_version on success' do
      initial_version = exam.lock_version
      patch "/api/exams/#{exam.id}/autosave",
            params: { exam: { title: 'New title', lock_version: initial_version } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
      expect(exam.reload.title).to eq('New title')
      expect(exam.reload.lock_version).to eq(initial_version + 1)
    end

    it 'returns 409 when the supplied lock_version is stale' do
      exam.update!(title: 'Server-side edit')
      patch "/api/exams/#{exam.id}/autosave",
            params: { exam: { title: 'Client stale', lock_version: 0 } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:conflict)
    end

    it 'accepts nested question params (Turbo-Frame saves from rail)' do
      topic = create(:topic)
      source = create(:source)
      q = create(:question, topic: topic, source: source, content: 'Old content')

      patch "/api/exams/#{exam.id}/autosave",
            params: { exam: { lock_version: exam.lock_version }, question: { id: q.id, content: 'New content' } }.to_json,
            headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(q.reload.content).to eq('New content')
    end
  end
end
