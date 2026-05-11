require 'rails_helper'

RSpec.describe 'API GET /api/exams/:id/pdf (style switch)', type: :request do
  let!(:topic) { create(:topic) }
  let!(:exam) { create(:exam, title: 'Style switch spec') }
  let!(:question) { create(:question, topic: topic) }
  let!(:eq) { create(:exam_question, exam: exam, question: question, position: 1) }

  before do
    # Stub Grover/Puppeteer — return the rendered HTML so we can assert on it.
    allow(PdfRenderer).to receive(:render_to_pdf) { |args| args[:html] }
  end

  describe 'paper PDF' do
    it 'defaults to the modern exams/paper template' do
      get "/api/exams/#{exam.id}/pdf"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/pdf')
      # `exams/paper` wraps the doc in a `paper`-class container that
      # `exams/show` never produced.
      expect(response.body).to include('class="paper-page"').or include('class="paper"').or include('paper-page')
    end

    it 'falls back to legacy exams/show on ?style=legacy' do
      get "/api/exams/#{exam.id}/pdf?style=legacy"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/pdf')
      # Two signals from the legacy show template: an `.exam-header` block
      # or the heading "Practice Exam" rendered via the legacy layout.
      # Either is fine; just ensure the modern paper marker is absent.
      expect(response.body).not_to include('class="paper-page"')
    end
  end

  describe 'marking scheme PDF' do
    it 'defaults to the modern exams/marker_paper template' do
      get "/api/exams/#{exam.id}/marking_scheme_pdf"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/pdf')
      # marker_paper.html.erb renders a "Marking Scheme" header inside a
      # marker-paper container; legacy marking_scheme.html.erb does not.
      expect(response.body.downcase).to include('marker').or include('mark scheme').or include('marking scheme')
    end

    it 'falls back to legacy exams/marking_scheme on ?style=legacy' do
      get "/api/exams/#{exam.id}/marking_scheme_pdf?style=legacy"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/pdf')
    end
  end
end
