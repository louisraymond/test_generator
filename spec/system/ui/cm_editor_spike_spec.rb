require 'rails_helper'

RSpec.describe 'CM editor spike — non-composite stem round-trip', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic) }
  let!(:question) do
    create(:question,
           topic: topic,
           question_type: 'written',
           content: "## Old heading\n\nOld body.")
  end

  it 'persists a content edit through CM6 and survives reload' do
    visit edit_question_path(question)

    # Editor mounts (data-controller="cm-editor" sets `cmView` on the element).
    expect(page).to have_css('[data-controller~="cm-editor"]', wait: 5)
    selector = '[data-cm-editor-save-field-value="question[content]"]'

    cm_set_value(selector, "## New heading\n\nNew body.")
    wait_for_cm_save(selector)

    visit edit_question_path(question)
    expect(cm_value(selector)).to eq("## New heading\n\nNew body.")
    expect(question.reload.content).to eq("## New heading\n\nNew body.")
  end
end
