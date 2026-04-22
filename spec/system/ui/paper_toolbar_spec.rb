# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exam paper toolbar', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let(:topic) { create(:topic) }
  let(:source) { create(:source) }
  let(:template) do
    create(:exam_template,
           subject: 'Physics',
           paper_number: '2',
           tier: 'higher')
  end
  let(:exam) do
    e = create(:exam,
               title: 'Midterm — Physics 2',
               exam_template: template,
               seed: 1234,
               duration_minutes: 90)
    q = create(:question, topic: topic, source: source, points: 4)
    create(:exam_question, exam: e, question: q, position: 1)
    e
  end

  it 'renders the exam-toolbar with title + status badge + mono meta + three buttons' do
    visit exam_path(exam)

    # Left side: title, "Ready" status dot, mono meta with seed.
    within('.exam-toolbar .l') do
      expect(page).to have_text('Midterm — Physics 2')
      expect(page).to have_css('.badge')
      expect(page).to have_css('.badge .dot')
      expect(page).to have_text(/seed/i)
    end

    # Right side: three action buttons in the design's order.
    within('.exam-toolbar .r') do
      labels = page.all('.btn').map { |b| b.text.strip }
      expect(labels).to eq(['Marking scheme', 'Regenerate', 'Download PDF'])
    end
  end

  it 'Download PDF button links to the exam.pdf URL' do
    visit exam_path(exam)
    pdf_link = page.find('.exam-toolbar .r a', text: 'Download PDF')
    expect(pdf_link[:href]).to end_with(".pdf")
  end

  it 'Marking scheme button links to the marking_scheme path' do
    visit exam_path(exam)
    ms_link = page.find('.exam-toolbar .r a', text: 'Marking scheme')
    expect(ms_link[:href]).to include('marking_scheme')
  end
end
