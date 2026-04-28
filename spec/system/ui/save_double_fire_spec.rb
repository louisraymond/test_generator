require 'rails_helper'

# Editor #51 — clicking the Save button must invoke each cm-editor's
# save() exactly once per click. The original `_paper_edit.html.erb`
# wired `click->save-chrome#save` on BOTH the parent action div AND
# the inner Save button; one real click bubbled through both, firing
# the action twice. With two part editors that produced 4 PATCHes
# per click, regularly tripping the `data-dirty="false"` budget on
# the concurrent-edits spec.
#
# This regression net asserts the single-fire invariant directly:
# count cm:saved events per editor on one click; expect 1, not 2.
RSpec.describe 'Save button single-fire invariant', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic)     { create(:topic) }
  let!(:composite) { create(:question, :composite, topic: topic) }

  it 'fires each editor save() exactly once per Save click' do
    visit edit_question_path(composite)
    selector = '[data-cm-editor-save-field-value="question[content]"]'
    expect(page).to have_css(selector, wait: 5)

    # Capture every cm:saved event that bubbles to window, keyed by
    # field id, so we can count occurrences per editor.
    page.execute_script(<<~JS)
      window.__savedEvents = [];
      document.addEventListener('cm:saved', (e) => {
        window.__savedEvents.push((e.detail && e.detail.fieldId) || '?');
      });
    JS

    cm_set_value(selector, 'Single edit.')
    find('[data-test-id="save-button"]').click

    # Wait until the chrome reports clean, then sample the counter.
    expect(page).to have_css('[data-test-id="save-button"][data-dirty="false"]', wait: 8)
    # Settle for a beat in case a stray double-fire is still in flight.
    sleep 0.2

    events = page.evaluate_script('window.__savedEvents')
    saves_for_field = events.count('question[content]')
    expect(saves_for_field).to eq(1),
      "expected exactly one cm:saved for question[content]; got #{saves_for_field} (events: #{events.inspect})"
  end
end
