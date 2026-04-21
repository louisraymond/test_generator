# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inspector rail', type: :request do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:exam) do
    exam = create(:exam, title: 'Rail exam')
    q = create(:question, topic: topic, source: source, points: 5, bloom_level: 'apply')
    create(:exam_question, exam: exam, question: q, position: 1)
    exam
  end
  let(:eq) { exam.exam_questions.first }

  describe 'GET /exam_questions/:id/rail' do
    it 'renders a rail body with Content, Marking, Metadata tabs' do
      get "/exam_questions/#{eq.id}/rail"
      expect(response).to have_http_status(:ok)
      body = response.body
      %w[Content Marking Metadata].each do |tab|
        expect(body).to include(tab)
      end
    end

    it 'renders a bloom-level select and points input in Metadata' do
      get "/exam_questions/#{eq.id}/rail"
      expect(response.body).to include('bloom_level')
      expect(response.body).to include('points')
    end

    it 'renders Content fields for the question stem' do
      get "/exam_questions/#{eq.id}/rail"
      expect(response.body).to include('question[content]')
    end

    it 'uses turbo-frame for drop-in replacement' do
      get "/exam_questions/#{eq.id}/rail"
      expect(response.body).to include('<turbo-frame id="rail-body"')
    end
  end
end
