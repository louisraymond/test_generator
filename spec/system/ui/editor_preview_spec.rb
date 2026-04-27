require 'rails_helper'

RSpec.describe 'CM editor — live preview decorations', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic)    { create(:topic) }
  let!(:question) { create(:question, topic: topic, content: 'This is **bold** and *italic*.') }

  let(:selector) { '[data-cm-editor-save-field-value="question[content]"]' }

  it 'shows raw asterisks when cursor is on the bold token' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)

    cm_set_cursor(selector, line: 1, col: 12)   # inside **bold**
    raw = page.find("#{selector} .cm-line").text
    expect(raw).to include('**bold**')
  end

  it 'hides asterisks and renders bold weight when cursor leaves the line' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)

    cm_set_cursor(selector, line: 1, col: 12)
    page.execute_script("document.activeElement.blur();")
    cm_set_cursor(selector, line: 1, col: 1)   # off-line by leaving via blur+refocus elsewhere

    # The decoration plugin marks bold spans with class cm-md-bold.
    expect(page).to have_css("#{selector} .cm-md-bold", text: 'bold')
    weight = page.evaluate_script(<<~JS)
      getComputedStyle(document.querySelector('#{selector} .cm-md-bold')).fontWeight
    JS
    expect(weight.to_i).to be >= 600
  end
end
