# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workspace canvas tab', type: :request do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:exam) do
    exam = create(:exam, title: 'Canvas target')
    q1 = create(:question, topic: topic, source: source, points: 3)
    q2 = create(:question, topic: topic, source: source, points: 5)
    create(:exam_question, exam: exam, question: q1, position: 1)
    create(:exam_question, exam: exam, question: q2, position: 2)
    exam
  end

  describe 'GET /workspace?tab=canvas&exam=:id' do
    it 'renders the 3-column canvas shell when an exam is selected' do
      get "/workspace?tab=canvas&exam=#{exam.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-canvas')           # shell wrapper
      expect(response.body).to include('canvas__qlist')         # left col
      expect(response.body).to include('canvas__preview')       # centre col
      expect(response.body).to include('canvas__rail')          # right col
    end

    it 'lists questions with drag handles' do
      get "/workspace?tab=canvas&exam=#{exam.id}"
      expect(response.body).to match(/class="qlist-item/)
      expect(response.body).to include('drag-handle')
    end

    it 'shows an empty-state when no exam is selected' do
      get '/workspace?tab=canvas'
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/Open a paper|Pick an exam|Select an exam|No exam selected/i)
    end

    it 'exposes a turbo-frame for the live paper preview' do
      get "/workspace?tab=canvas&exam=#{exam.id}"
      expect(response.body).to include('<turbo-frame id="paper-preview"')
    end
  end

  describe 'GET /exams/:id/preview_frame' do
    it 'returns a turbo-frame with the paper body' do
      get "/exams/#{exam.id}/preview_frame"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="paper-preview"')
      expect(response.body).to include('paper')
    end
  end
end
