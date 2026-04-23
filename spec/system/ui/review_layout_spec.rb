require 'rails_helper'

# Review & Export tab layout contract (Wave 6).
#
# Guarantees the user never sees the "ugly" state we just fixed:
#   - Papers must keep A4 aspect ratio (height ≈ width × √2)
#   - At wide viewports both student + marker panes are visible
#     side-by-side, filling the main area
#   - At narrow viewports the panes collapse to a single visible pane
#     with a Student/Marker toggle
#   - The workspace `.main` gives review full-bleed (no 1280px cap / 56px
#     padding) so there's no squeeze + transform-scale hack
RSpec.describe 'Review tab layout', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { Topic.create!(name: 'Review-layout topic') }
  let!(:question) do
    Question.create!(topic: topic, question_type: 'written',
                     content: 'Write about x', answer: 'Answer', points: 2)
  end
  let!(:exam) do
    Exam.create!(title: 'Review layout exam').tap do |e|
      ExamQuestion.create!(exam: e, question: question, position: 1)
    end
  end

  describe 'on a wide viewport (≥ 1440px)' do
    before do
      page.driver.browser.manage.window.resize_to(1600, 900)
      visit workspace_path(tab: 'review', exam: exam.id)
    end

    it 'gives review tab full-bleed — no 1280px cap or 56px padding' do
      main_padding = page.evaluate_script("getComputedStyle(document.querySelector('.main')).padding")
      main_max_width = page.evaluate_script("getComputedStyle(document.querySelector('.main')).maxWidth")
      expect(main_padding).to eq('0px')
      expect(main_max_width).to eq('none')
    end

    it 'renders two panes side-by-side (student + marker)' do
      expect(page).to have_css('.review__pane.review__student', visible: :visible)
      expect(page).to have_css('.review__pane.review__marker',  visible: :visible)
    end

    it 'keeps each paper at an A4 aspect ratio (±2%)' do
      # Check the `.paper-sheet` wrappers in the parent doc. Each wrapper
      # is width-responsive and locks its height via `aspect-ratio`.
      selectors = %w[.review__student .paper-sheet .review__marker .paper-sheet]
      bounds = page.evaluate_script(<<~JS)
        (() => {
          const el = document.querySelector('.review__student .paper-sheet');
          if (!el) return null;
          const r = el.getBoundingClientRect();
          return { w: r.width, h: r.height };
        })();
      JS
      expect(bounds).not_to be_nil
      ratio = bounds['h'].to_f / bounds['w'].to_f
      expect(ratio).to be_within(0.03).of(297.0 / 210.0) # A4 = √2 ≈ 1.414
    end

    it 'hides the pane toggle — both panes already visible' do
      expect(page).not_to have_css('.review__toggle.is-active', visible: :visible)
    end
  end

  describe 'on a narrow viewport (< 1200px)' do
    before do
      page.driver.browser.manage.window.resize_to(1000, 800)
      visit workspace_path(tab: 'review', exam: exam.id)
    end

    it 'shows the Student / Marker toggle' do
      expect(page).to have_css('.review__toggle', visible: :visible)
      expect(page).to have_button('Student', visible: :visible)
      expect(page).to have_button('Marker',  visible: :visible)
    end

    it 'shows only the selected pane at a time' do
      # Default: student active.
      student_display = page.evaluate_script("getComputedStyle(document.querySelector('.review__student')).display")
      marker_display  = page.evaluate_script("getComputedStyle(document.querySelector('.review__marker')).display")
      expect(student_display).not_to eq('none')
      expect(marker_display).to eq('none')

      click_button 'Marker'

      student_display = page.evaluate_script("getComputedStyle(document.querySelector('.review__student')).display")
      marker_display  = page.evaluate_script("getComputedStyle(document.querySelector('.review__marker')).display")
      expect(student_display).to eq('none')
      expect(marker_display).not_to eq('none')
    end
  end
end
