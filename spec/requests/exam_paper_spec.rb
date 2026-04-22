# frozen_string_literal: true

require 'rails_helper'

# Phase 1: student-paper PDF redesign. The PDF route renders the new paper
# template with a cover page, running head/foot, and parametric answer regions.
#
# We assert on the HTML rendered into `layout: 'pdf'` (the same HTML that
# Grover then snapshots) so these specs stay fast and don't depend on
# Chromium being available in CI.
RSpec.describe 'Exams paper (student PDF redesign)', type: :request do
  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:template) do
    create(:exam_template,
           subject: 'Mathematics',
           paper_number: '3',
           tier: 'higher',
           subtitle: 'Mock · Summer 2026',
           rubric: 'Answer all questions in the spaces provided. Show your working.',
           centre_name: 'Heathbank Academy',
           candidate_fields: ['Full name', 'Centre number', 'Candidate number'],
           grade_boundaries: { 'A*' => 54, 'A' => 46, 'B' => 38 })
  end
  let(:exam) do
    exam = create(:exam,
                  title: 'Calculus, Linear Algebra & Probability',
                  exam_template: template,
                  exam_date: Date.new(2026, 4, 17),
                  seed: 4721,
                  duration_minutes: 90)
    [2, 4, 5].each_with_index do |points, i|
      q = create(:question, topic: topic, source: source, points: points,
                            content: "Question #{i + 1}")
      create(:exam_question, exam: exam, question: q, position: i + 1)
    end
    exam
  end

  describe 'GET /exams/:id/paper' do
    it 'responds 200 and renders the redesigned paper HTML' do
      get paper_exam_path(exam)
      expect(response).to have_http_status(:ok)
    end

    it 'renders the cover page eyebrow, title, metadata grid, rubric' do
      get paper_exam_path(exam)
      body = response.body
      # Eyebrow is built from subject · paper · tier, uppercased by CSS.
      expect(body).to include('Mathematics')
      expect(body).to include('Paper 3')
      expect(body).to include('Higher')
      # Title on the cover.
      expect(body).to include('Calculus, Linear Algebra &amp; Probability')
      # Metadata grid — 4 cells.
      expect(body).to match(/cover__cell/)
      expect(body).to include('Duration')
      expect(body).to include('Total marks')
      # Rubric text.
      expect(body).to include('Answer all questions in the spaces provided')
    end

    it 'scales answer regions by question marks' do
      get paper_exam_path(exam)
      body = response.body
      # 2-mark → lines--2; 4-mark → workbox--md; 5-mark → workbox--lg.
      expect(body).to include('lines--2')
      expect(body).to include('workbox--md')
      expect(body).to include('workbox--lg')
    end

    it 'renders running head and foot on interior pages' do
      get paper_exam_path(exam)
      expect(response.body).to include('runhead')
      expect(response.body).to include('runfoot')
    end

    it 'does not render the Specimen watermark (removed per product feedback)' do
      get paper_exam_path(exam)
      expect(response.body).not_to match(/class="wmk"/)
      expect(response.body).not_to include('Specimen · do not redistribute')
    end

    it 'falls back to sensible defaults for exams without a template' do
      no_template_exam = create(:exam, title: 'Ad-hoc exam', seed: 1)
      q = create(:question, topic: topic, source: source, points: 1)
      create(:exam_question, exam: no_template_exam, question: q, position: 1)

      get paper_exam_path(no_template_exam)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ad-hoc exam')
    end
  end

  describe 'GET /exams/:id.pdf' do
    # The PDF format uses the same template, just wrapped in layout: 'pdf'
    # and piped through Grover. We only test that the request succeeds here;
    # the HTML content is covered above.
    it 'responds with application/pdf' do
      # Stub Grover so we don't spawn Chromium in unit specs.
      allow(PdfRenderer).to receive(:render_to_pdf).and_return('%PDF-1.4 stub')
      get exam_path(exam, format: :pdf)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/pdf')
    end
  end
end
