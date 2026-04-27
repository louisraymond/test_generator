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

  context 'heading decoration' do
    let!(:heading_question) do
      create(:question, topic: topic, content: "## Heading line\n\nbody paragraph")
    end

    it 'shows raw `## ` when cursor is on the heading line' do
      visit edit_question_path(heading_question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 1)
      raw = page.find("#{selector} .cm-line", match: :first).text
      expect(raw).to include('## Heading line')
    end

    it 'hides `## ` and applies cm-md-heading-2 with larger font when cursor is off the heading line' do
      visit edit_question_path(heading_question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 1)
      cm_set_cursor(selector, line: 3, col: 1)   # move to body line

      expect(page).to have_css("#{selector} .cm-md-heading-2", text: 'Heading line')
      size = page.evaluate_script(<<~JS)
        (() => {
          const el = document.querySelector('#{selector} .cm-md-heading-2');
          const parent = el.closest('.cm-line') || el.parentElement;
          const elPx     = parseFloat(getComputedStyle(el).fontSize);
          const parentPx = parseFloat(getComputedStyle(parent).fontSize);
          return parentPx > 0 ? elPx / parentPx : 0;
        })()
      JS
      expect(size.to_f).to be >= 1.3
    end
  end

  context 'inline code decoration' do
    let!(:code_question) do
      create(:question, topic: topic, content: "Use `puts hello` to print.")
    end

    it 'shows raw backticks when cursor is on the inline-code line' do
      visit edit_question_path(code_question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 7)   # inside `puts hello`
      raw = page.find("#{selector} .cm-line", match: :first).text
      expect(raw).to include('`puts hello`')
    end

    it 'hides backticks and applies cm-md-code-inline with mono font when cursor is off the line' do
      visit edit_question_path(code_question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 7)
      page.execute_script("document.activeElement.blur();")
      cm_set_cursor(selector, line: 1, col: 1)

      expect(page).to have_css("#{selector} .cm-md-code-inline", text: 'puts hello')
      family = page.evaluate_script(<<~JS)
        getComputedStyle(document.querySelector('#{selector} .cm-md-code-inline')).fontFamily
      JS
      expect(family.to_s.downcase).to match(/mono|courier|consolas|menlo|cascadia/)
    end
  end

  context 'inline math' do
    let!(:question) { create(:question, topic: topic, content: 'Inline $H_A = 5.6$ here.') }

    it 'shows raw $H_A$ when cursor on the line' do
      visit edit_question_path(question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 8)
      raw = page.find("#{selector} .cm-line").text
      expect(raw).to include('$H_A = 5.6$')
    end

    it 'renders KaTeX when cursor leaves the line' do
      visit edit_question_path(question)
      expect(page).to have_css(selector, wait: 5)

      cm_set_cursor(selector, line: 1, col: 8)
      page.execute_script("document.activeElement.blur();")

      expect(page).to have_css("#{selector} .katex", wait: 3)
    end
  end
end
