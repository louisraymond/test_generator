# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Marker copy mark scheme', type: :request do
  let(:topic)    { create(:topic) }
  let(:source)   { create(:source) }
  let(:template) do
    create(:exam_template,
           subject: 'Mathematics', paper_number: '3', tier: 'higher',
           grade_boundaries: { 'A*' => 54, 'A' => 46, 'B' => 38 },
           principles_of_marking: 'Accept any equivalent phrasing where meaning is unambiguously preserved.')
  end
  let(:exam) do
    exam = create(:exam, title: 'P3H', exam_template: template, exam_date: Date.new(2026, 4, 17))
    q1 = create(:question, topic: topic, source: source, points: 5, content: 'Compute the gradient.')
    create(:marking_step, question: q1, kind: 'm', n: 1, text: 'State gradient formula.')
    create(:marking_step, question: q1, kind: 'a', n: 1, text: 'Evaluate at w0.',
                          accepts: ['3/10', '0.3'], rejects: ['0.33'])
    q2 = create(:question, topic: topic, source: source, points: 2, content: 'Free-text legacy Q')
    # q2 has no marking_steps → falls back to Question#answer
    create(:exam_question, exam: exam, question: q1, position: 1)
    create(:exam_question, exam: exam, question: q2, position: 2)
    exam
  end

  describe 'GET /exams/:id/marking_scheme?variant=marker' do
    it 'responds 200 and renders the marker cover + per-question cards' do
      get marking_scheme_exam_path(exam, variant: 'marker')
      expect(response).to have_http_status(:ok)
      body = response.body

      # Marker cover — grade boundaries + principles of marking.
      expect(body).to include("Marker's copy")
      expect(body).to match(/A\*/)
      expect(body).to include('Accept any equivalent phrasing')

      # Per-question cards with credit pills.
      expect(body).to match(/class="ms-q/m)
      expect(body).to match(/class="mark mark--m/)
      expect(body).to match(/class="mark mark--a/)

      # Accept/Reject rows render the arrays.
      expect(body).to include('3/10')
      expect(body).to include('0.33')
    end

    it 'falls back to free-text answer for questions without marking steps' do
      get marking_scheme_exam_path(exam, variant: 'marker')
      expect(response.body).to include('Free-text legacy Q').or include('legacy')
    end

    it 'defaults to the marker variant when no variant param is given' do
      get marking_scheme_exam_path(exam)
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/class="ms-q/m)
    end
  end
end
