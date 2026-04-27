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
    wait_for_cm_save(sel0)
    cm_set_value(sel1, 'Edited B.')
    wait_for_cm_save(sel1)

    parts = composite.reload.options['parts']
    expect(parts[0]['stem']).to eq('Edited A.')
    expect(parts[1]['stem']).to eq('Edited B.')
  end

  it 'does not merge a heading with the next paragraph when the source contains both' do
    composite.update!(content: "## Heading\n\nbody paragraph")

    visit edit_question_path(composite)
    selector = '[data-cm-editor-save-field-value="question[content]"]'
    expect(page).to have_css(selector, wait: 5)

    # Simulate the original bug's scenario: write back the same text, persist, reload.
    cm_set_value(selector, "## Heading\n\nbody paragraph")
    wait_for_cm_save(selector)

    visit edit_question_path(composite)
    expect(cm_value(selector)).to eq("## Heading\n\nbody paragraph")

    # The original bug produced "<h2>Heading body paragraph</h2>" — make sure
    # the saved content still has the blank line separating the blocks.
    expect(composite.reload.content).to include("\n\n")
  end

  it 'inserts a new part via the add-part button and the new editor mounts' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index]', count: 2, wait: 5)

    # Add a new part after part (a).
    within('[data-part-index="0"]') { click_button('Add part below', wait: 5) }

    # New part appears at index 1; original part B shifts to index 2.
    expect(page).to have_css('[data-part-index]', count: 3, wait: 5)
    new_sel = '[data-part-index="1"] [data-controller~="cm-editor"]'
    expect(page).to have_css(new_sel, wait: 5)

    cm_set_value(new_sel, 'Newly inserted part.')
    # Forward-compat with Editor #40 — once the explicit Save button lands the
    # debounced autosave goes away, so click Save when present.
    if page.has_css?('[data-test-id="save-button"]', wait: 1)
      find('[data-test-id="save-button"]').click
    end
    wait_for_cm_save(new_sel)

    parts = composite.reload.options['parts']
    expect(parts.length).to eq(3)
    expect(parts[1]['stem']).to eq('Newly inserted part.')
    expect(parts[1]['type']).to eq('written')
    expect(parts[1]['marks']).to eq(1)
    expect(parts[2]['stem']).to eq('Part B.')   # original part B shifted
  end
end
