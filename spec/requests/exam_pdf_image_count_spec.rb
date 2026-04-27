# frozen_string_literal: true

# Regression net for the GoodNotes-lag PDF investigation.
#
# Background: the exam paper PDF was shipping ~126 raster `/Subtype /Image`
# stamps because Skia/PDF rasterises CSS `repeating-linear-gradient` ruled-line
# backgrounds (and `linear-gradient` accent stripes) when emitting a PDF. The
# mark scheme PDF, which has no ruled-line answer regions, ships with 0 raster
# images. With ~4 images per page, GoodNotes' on-iPad redraw can't keep up.
#
# This spec exercises the real production path:
#   ExamBuilder -> exams/show -> layout 'pdf' -> Grover -> Chromium -> Skia/PDF.
#
# It asserts that the resulting PDF embeds fewer than 5 `/Subtype /Image`
# entries. The threshold accommodates a small number of legitimate diagram
# images per exam (e.g. figure images attached to questions) and is bumpable
# only if a new exam type genuinely needs more.
#
# See also:
#   - app/assets/stylesheets/paper.css (the @media print overrides that fix this)
#   - app/assets/stylesheets/exam.css  (.answer-lines--ruled override)
#   - The investigation report under .claude/plans/i-want-you-to-goofy-micali.md

require 'rails_helper'

RSpec.describe 'Exam PDF rasterisation budget', type: :request do
  let!(:topic) { create(:topic) }
  let!(:topic_module) { create(:topic_module, topic: topic, position: 0) }

  # A spread of question types that exercises the high-volume gradient surfaces:
  #   - written / markdown / code_analysis -> .lines / .answer-lines ruled regions
  #   - calculation -> .workbox (also a repeating-linear-gradient when ruled)
  #   - multiple_choice -> options list, no ruled lines (sanity)
  before do
    create_list(:question, 3, topic: topic, topic_module: topic_module, question_type: 'written', points: 4)
    create_list(:question, 2, :calculation, topic: topic, topic_module: topic_module, points: 5)
    create_list(:question, 2, :multiple_choice, topic: topic, topic_module: topic_module, points: 1)
    create_list(:question, 2, topic: topic, topic_module: topic_module, question_type: 'written', points: 8)
  end

  it 'embeds fewer than 5 raster image stamps in the generated PDF' do
    exam = ExamBuilder.call(
      topic_ids: [topic.id],
      count: 9,
      title: 'PDF image-count regression spec',
      strict: false
    )

    get pdf_api_exam_path(exam)
    expect(response).to have_http_status(:ok), response.body.first(500)

    body  = response.body.b
    count = body.scan('/Subtype /Image').length

    expect(count).to be < 5,
      "Exam PDF contains #{count} raster /Subtype /Image entries; expected <5. " \
      'Most likely cause: a CSS gradient (repeating-linear-gradient or non-trivial ' \
      'linear-gradient) was added without an @media print override, and Skia/PDF ' \
      'rasterised it. Sweep paper.css and exam.css for new gradient backgrounds.'
  end
end
