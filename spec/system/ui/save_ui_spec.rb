require 'rails_helper'

# Editor ticket #40 — Explicit Save button + dirty indicator.
#
# Design contract item 4 (`/.claude/plans/i-want-you-to-goofy-micali.md`):
# "Explicit Save button — no background autosave. Permissive validation:
#  invalid states surface as warnings, not blocks. Save state shown as
#  `● unsaved` while dirty, `✓ saved Nm ago` when committed."
#
# These five specs lock the design contract:
#   1. Page loads in is-saved state.
#   2. Editing any field flips state to is-dirty.
#   3. Click Save → POSTs all dirty fields → state returns to is-saved.
#   4. Cmd/Ctrl-S triggers the same.
#   5. No autosave: typing without clicking Save must NOT persist.
RSpec.describe 'Save UI — explicit Save + dirty indicator', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic)    { create(:topic) }
  let!(:question) do
    create(:question,
           topic: topic,
           question_type: 'written',
           content: 'Original body.')
  end

  let(:selector) { '[data-cm-editor-save-field-value="question[content]"]' }

  it 'loads in is-saved state with a "saved …" timestamp' do
    visit edit_question_path(question)
    expect(page).to have_css('[data-test-id="save-button"]', wait: 5)

    btn = page.find('[data-test-id="save-button"]')
    expect(btn['data-dirty']).to eq('false')
    expect(page).to have_css('[data-save-chrome-target="state"]', text: /saved/i)
  end

  it 'flips to is-dirty when any field is edited' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)
    expect(page).to have_css('[data-test-id="save-button"][data-dirty="false"]')

    cm_set_value(selector, 'Edited body — not yet saved.')

    expect(page).to have_css('[data-test-id="save-button"][data-dirty="true"]', wait: 3)
    expect(page).to have_css('[data-save-chrome-target="state"]', text: /unsaved/i)
  end

  it 'persists on click Save and returns to is-saved' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)

    cm_set_value(selector, 'Saved via click.')
    expect(page).to have_css('[data-test-id="save-button"][data-dirty="true"]', wait: 3)

    page.find('[data-test-id="save-button"]').click
    wait_for_cm_save(selector)

    expect(page).to have_css('[data-test-id="save-button"][data-dirty="false"]', wait: 3)
    expect(page).to have_css('[data-save-chrome-target="state"]', text: /saved/i)
    expect(question.reload.content).to eq('Saved via click.')
  end

  it 'persists on Cmd/Ctrl-S keyboard shortcut' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)

    cm_set_value(selector, 'Saved via keyboard.')
    expect(page).to have_css('[data-test-id="save-button"][data-dirty="true"]', wait: 3)

    # Dispatch a synthetic Cmd-S keydown on window so the Stimulus
    # `keydown.meta+s@window` binding fires regardless of focus state.
    page.execute_script(<<~JS)
      const ev = new KeyboardEvent('keydown', {
        key: 's', code: 'KeyS', metaKey: true, ctrlKey: true,
        bubbles: true, cancelable: true,
      });
      window.dispatchEvent(ev);
    JS
    wait_for_cm_save(selector)

    expect(page).to have_css('[data-test-id="save-button"][data-dirty="false"]', wait: 3)
    expect(question.reload.content).to eq('Saved via keyboard.')
  end

  it 'does NOT autosave on debounced change — no Save click means no persistence' do
    visit edit_question_path(question)
    expect(page).to have_css(selector, wait: 5)

    cm_set_value(selector, 'Typed but never saved.')
    # Wait well past any debounce window the controller may have used.
    sleep 1.2

    visit edit_question_path(question)
    # The persisted content must be unchanged because Save was never clicked.
    expect(question.reload.content).to eq('Original body.')
  end
end
