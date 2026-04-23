require 'rails_helper'

# Canvas tab layout contract (Wave 6 — fixes the overlap bug the user
# flagged). The canvas is a self-contained 3-column grid, so the
# workspace `.main` must strip its padding + max-width constraint
# when the canvas tab is active — otherwise the 794 px paper preview
# overflows into the inspector rail.
RSpec.describe 'Canvas tab layout', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { Topic.create!(name: 'Canvas-layout topic') }
  let!(:question) do
    Question.create!(topic: topic, question_type: 'written',
                     content: 'Q', answer: 'A', points: 2)
  end
  let!(:exam) do
    Exam.create!(title: 'Canvas layout exam').tap do |e|
      ExamQuestion.create!(exam: e, question: question, position: 1)
    end
  end

  it 'lets the canvas tab go full-bleed inside .main' do
    page.driver.browser.manage.window.resize_to(1600, 900)
    visit workspace_path(tab: 'canvas', exam: exam.id)

    main_padding   = page.evaluate_script("getComputedStyle(document.querySelector('.main')).padding")
    main_max_width = page.evaluate_script("getComputedStyle(document.querySelector('.main')).maxWidth")
    expect(main_padding).to eq('0px')
    expect(main_max_width).to eq('none')
  end

  it 'keeps the canvas 3-column grid within viewport width (no overlap)' do
    page.driver.browser.manage.window.resize_to(1600, 900)
    visit workspace_path(tab: 'canvas', exam: exam.id)

    canvas_right = page.evaluate_script(<<~JS)
      Math.round(document.querySelector('.canvas').getBoundingClientRect().right)
    JS
    rail_right = page.evaluate_script(<<~JS)
      Math.round(document.querySelector('.canvas__rail').getBoundingClientRect().right)
    JS
    viewport_width = page.evaluate_script('window.innerWidth')

    # Rail's right edge must sit within the canvas (no horizontal clipping
    # of the rail outside its own parent) and within the viewport.
    expect(rail_right).to be <= canvas_right
    expect(canvas_right).to be <= viewport_width + 1 # allow 1px rounding
  end
end
