require 'rails_helper'

RSpec.describe 'Composite question editor — workflow', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic)     { create(:topic) }
  let!(:composite) { create(:question, :composite, topic: topic) }

  it 'edits the parent stem and persists across reload' do
    visit edit_question_path(composite)
    selector = '[data-cm-editor-save-field-value="question[content]"]'
    expect(page).to have_css(selector, wait: 5)

    cm_set_value(selector, 'New parent stem.')
    wait_for_cm_save(selector)

    visit edit_question_path(composite)
    expect(cm_value(selector)).to eq('New parent stem.')
    expect(composite.reload.content).to eq('New parent stem.')
  end
end
