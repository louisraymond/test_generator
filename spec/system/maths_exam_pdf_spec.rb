# frozen_string_literal: true

# End-to-end PDF generation spec. Covers the full production path:
#   POST /api/exams -> ExamBuilder -> render_to_string(layout: 'pdf') ->
#   PdfRenderer -> Grover -> Chromium -> KaTeX -> final PDF bytes.
#
# Guards against every regression shipped in the initial maths exemplar build:
#   - Grover `display_url` (not `base_url`) — missing image in PDF.
#   - `layout: false` on marking-scheme actions — raw LaTeX in text stream.
#   - Dark-mode CSS leaking into paper — white-on-white invisible text.
#   - Redcarpet `^` / `_` eating math — <sup>/<em> tags inside formulas.
#
# Host dependency: pdftotext (Poppler).
#   macOS: brew install poppler
#   Debian/Ubuntu: apt-get install poppler-utils
# Chromium is already required by the existing spec/system/exam_display_spec.rb.

require 'rails_helper'
require 'support/maths_seed_loader'
require 'tempfile'

RSpec.describe 'Maths exam PDF pipeline', type: :request do
  before(:all) do
    skip 'pdftotext (Poppler) not installed on PATH' unless system('which pdftotext > /dev/null 2>&1')
    MathsSeedLoader.load_exemplars!
  end

  let(:topic_id) { MathsSeedLoader.exemplar_questions.first.topic_id }

  let(:exam_id) do
    post '/api/exams',
      params: {
        topic_ids: [topic_id],
        count: 6,
        title: 'Maths PDF integration smoke',
        duration_minutes: 60
      }.to_json,
      headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:created), response.body.first(500)
    JSON.parse(response.body).fetch('id')
  end

  let(:pdf_bytes) do
    get "/api/exams/#{exam_id}/pdf"
    expect(response).to have_http_status(:ok), response.body.first(500)
    response.body.b # force ASCII-8BIT: response.body is UTF-8-tagged even when binary
  end

  let(:pdf_text) do
    Tempfile.create(['maths-exam', '.pdf']) do |f|
      f.binmode
      f.write(pdf_bytes)
      f.flush
      `pdftotext -layout #{f.path} -`
    end
  end

  it 'emits a non-trivial PDF document' do
    expect(pdf_bytes[0, 4]).to eq('%PDF')
    expect(pdf_bytes.bytesize).to be > 20_000
  end

  it 'lets KaTeX render every math command (no raw \\mid, \\mathbf, \\frac, \\lVert in the text layer)' do
    raw_commands = %w[\\mid \\mathbf \\frac \\lVert \\displaystyle \\cos \\sin \\int \\sum]
    leaks = raw_commands.select { |cmd| pdf_text.include?(cmd) }
    expect(leaks).to be_empty,
      "These LaTeX commands leaked raw into the PDF (KaTeX did not render): #{leaks.inspect}"
  end

  it 'does not leak Redcarpet HTML tags into math spans' do
    expect(pdf_text).not_to include('<sup>')
    expect(pdf_text).not_to include('</sup>')
    expect(pdf_text).not_to include('<em>')
  end

  # NOT COVERED HERE (and honestly-so):
  #   * Figure-image loaded vs. broken. Request specs don't boot a web server
  #     that Grover's Chromium can reach for relative `/assets/...` fetches;
  #     the alt text always ends up in the PDF. The `display_url` pin spec in
  #     spec/services/pdf_renderer_spec.rb guards the root cause instead.
  #   * Visual colour of text (dark-mode regression). Binary regex on PDF bytes
  #     hits encoding headaches; the screen-side check belongs in a future
  #     Capybara assertion on `getComputedStyle(body).color` in exam_display_spec.
end
