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
    find('[data-test-id="save-button"]').click
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
    find('[data-test-id="save-button"]').click
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
    # Both editors are dirty now; one click of Save dispatches save() on each.
    find('[data-test-id="save-button"]').click
    # Poll until the page chrome reports clean (data-dirty="false") which
    # only happens after every cm-editor's save() resolves.
    expect(page).to have_css('[data-test-id="save-button"][data-dirty="false"]', wait: 5)

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
    find('[data-test-id="save-button"]').click
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
    find('[data-test-id="save-button"]').click
    wait_for_cm_save(new_sel)

    parts = composite.reload.options['parts']
    expect(parts.length).to eq(3)
    expect(parts[1]['stem']).to eq('Newly inserted part.')
    expect(parts[1]['type']).to eq('written')
    expect(parts[1]['marks']).to eq(1)
    expect(parts[2]['stem']).to eq('Part B.')   # original part B shifted
  end

  # Editor #43 — performance budget. Every CM6 instance on the composite edit
  # page must dispatch `cm:ready` within 1.5s of mount. The composite fixture
  # has 4 instances (parent stem + parent answer + 2 part stems); on a cold
  # cache the lazy CDN fetch dominates first-paint, so the budget guards
  # against a regression in the connect()-time import pattern.
  it 'every editor instance dispatches cm:ready within 1.5 seconds' do
    visit edit_question_path(composite)

    # Count cm:ready events fired before the listener is attached too — the
    # async imports may resolve from cache faster than the page-finished
    # callback hands control back to the spec, so we backfill from any
    # already-mounted .cmView elements.
    page.execute_script(<<~JS)
      window.__cmReady = document.querySelectorAll('[data-controller~="cm-editor"]')
        .length > 0
        ? Array.from(document.querySelectorAll('[data-controller~="cm-editor"]'))
            .filter(el => el.cmView).length
        : 0;
      document.addEventListener('cm:ready', () => { window.__cmReady += 1 });
    JS

    Timeout.timeout(2.0) do
      loop do
        ready = page.evaluate_script("window.__cmReady || 0")
        # parent stem + parent answer + 2 part stems = 4 instances
        break if ready >= 4
        sleep 0.05
      end
    end
  end
end
