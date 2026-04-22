# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workspace review & export tab', type: :request do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:exam) do
    exam = create(:exam, title: 'Review target', seed: 1234)
    q = create(:question, topic: topic, source: source, points: 3)
    create(:exam_question, exam: exam, question: q, position: 1)
    exam
  end

  describe 'GET /workspace?tab=review&exam=:id' do
    it 'renders side-by-side student + mark scheme iframes' do
      get "/workspace?tab=review&exam=#{exam.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('review__student')
      expect(response.body).to include('review__marker')
      expect(response.body).to include('src="/exams/')
    end

    it 'exposes an export rail with PDF links and seed input' do
      get "/workspace?tab=review&exam=#{exam.id}"
      expect(response.body).to include('review-export')
      expect(response.body).to match(/\.pdf|format=pdf/)
      expect(response.body).to include('name="seed"')
    end

    it 'shows an empty state when no exam is selected' do
      get '/workspace?tab=review'
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/Preview a paper|Pick an exam|No exam selected|Select an exam/i)
    end
  end
end
