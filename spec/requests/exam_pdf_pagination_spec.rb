# frozen_string_literal: true

# Guards the height-aware page packer (PdfHelper#pack_exam_questions):
# every .paper block must fit one physical A4 sheet. If
# estimated_question_height ever underestimates, a .paper overflows 297mm,
# Chromium spills the excess onto an extra sheet, and the physical page
# count exceeds the .paper block count. Runs the real production path
# (exams -> layout 'pdf' -> Grover -> Chromium -> Skia/PDF), like the
# rasterisation-budget spec.
require 'rails_helper'

RSpec.describe 'Exam PDF pagination (no .paper overflow)', type: :request do
  let!(:topic) { create(:topic) }
  let!(:topic_module) { create(:topic_module, topic: topic, position: 0) }

  before do
    long_stem = <<~STEM.strip
      **T2.X — Break or defend** A colleague proposes the following architecture: #{'every write is appended to a shared log and acknowledged only after a quorum of replicas has confirmed the append, while reads are served from any replica without further coordination. ' * 3}

      (a) State the guarantee this design does and does not provide. (b) Construct the interleaving that violates it. (c) Propose the minimal change that restores it, and name its cost.
    STEM

    create_list(:question, 6, topic: topic, topic_module: topic_module,
                              question_type: 'markdown', points: 2, answer_size: 'short',
                              content: 'State the property and the mechanism behind it.')
    create_list(:question, 4, topic: topic, topic_module: topic_module,
                              question_type: 'markdown', points: 6, answer_size: 'long',
                              content: long_stem)
    create_list(:question, 2, :calculation, topic: topic, topic_module: topic_module, points: 5)
  end

  it 'renders exactly one physical PDF page per .paper block' do
    exam = ExamBuilder.call(topic_ids: [topic.id], count: 12,
                            title: 'Pagination regression', strict: true)

    get paper_exam_path(exam)
    blocks = Nokogiri::HTML(response.body).css('.paper').size

    get pdf_api_exam_path(exam)
    expect(response).to have_http_status(:ok), response.body.first(500)
    physical = response.body.b.scan(%r{/Type\s*/Page[^s]}).size

    expect(physical).to eq(blocks),
      "PDF has #{physical} physical pages for #{blocks} .paper blocks — a .paper overflowed A4. " \
      'PdfHelper::PAGE_BUDGET or estimated_question_height is underestimating.'
  end
end
