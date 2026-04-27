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

  it 'edits a sub-part stem and persists across reload' do
    visit edit_question_path(composite)
    selector = '[data-part-index="1"] [data-controller~="cm-editor"]'
    expect(page).to have_css(selector, wait: 5)

    cm_set_value(selector, 'Revised B.')
    wait_for_cm_save(selector)

    visit edit_question_path(composite)
    expect(cm_value(selector)).to eq('Revised B.')
    expect(composite.reload.options['parts'][1]['stem']).to eq('Revised B.')
    expect(composite.reload.options['parts'][1]['type']).to eq('calculation')  # untouched
  end

  it 'preserves both pending edits when the user switches between part editors' do
    visit edit_question_path(composite)
    sel0 = '[data-part-index="0"] [data-controller~="cm-editor"]'
    sel1 = '[data-part-index="1"] [data-controller~="cm-editor"]'

    cm_set_value(sel0, 'Edited A.')
    cm_set_value(sel1, 'Edited B.')
    wait_for_cm_save(sel0)
    wait_for_cm_save(sel1)

    parts = composite.reload.options['parts']
    expect(parts[0]['stem']).to eq('Edited A.')
    expect(parts[1]['stem']).to eq('Edited B.')
  end
end
