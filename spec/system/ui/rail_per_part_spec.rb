require 'rails_helper'

# Editor ticket #10 — Rail per-part inspector + type-switch flow.
#
# Design contract Flows A·03 + A·04
# (`/.claude/plans/i-want-you-to-goofy-micali.md`):
#   - Clicking a composite part on the paper highlights it (left accent
#     bar) AND swaps the rail's Content panel from question-level chrome
#     to a part-level inspector — type pills, marks input, answer_size
#     selector, and (where applicable) answer_label / unit fields.
#   - Switching the type via a different pill triggers a yellow-banner
#     warning ("switching type will reset type-specific options. stem &
#     metadata kept.") with Confirm / Cancel; only Confirm fires the
#     PATCH and the paper morphs in place to the new type's renderer.
#   - All edits route through `options_patch update_part`. The Save
#     button reflects dirty state via `cm:dirty` / `cm:saved` events.
RSpec.describe 'Rail per-part inspector — Flow A·03/04', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic) }
  let!(:composite) do
    create(:question,
           topic: topic,
           question_type: 'composite',
           content: 'Parent stem.',
           answer:  'Parent answer.',
           points:  6,
           options: {
             'parts' => [
               { 'stem' => 'Part A.', 'type' => 'written',     'marks' => 2,
                 'answer_size' => 'medium' },
               { 'stem' => 'Part B.', 'type' => 'calculation', 'marks' => 3,
                 'answer_label' => 'x', 'unit' => 'm' },
             ],
           })
  end

  it 'highlights the clicked part with a left accent bar' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    page.find('[data-part-index="0"] .composite__label').click

    expect(page).to have_css('[data-part-index="0"].is-selected', wait: 3)
    # Sibling parts must NOT be marked as selected.
    expect(page).to have_no_css('[data-part-index="1"].is-selected')
  end

  it 'shows part-level chrome in the rail when a part is selected' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    page.find('[data-part-index="0"] .composite__label').click

    expect(page).to have_css('[data-rail-part-inspector-target="panel"]', wait: 3)
    within('[data-rail-part-inspector-target="panel"]') do
      expect(page).to have_text('part (a)')
      expect(page).to have_text('written', normalize_ws: true)
      expect(page).to have_css('[data-rail-part-inspector-target="typePill"]')
      # We expose pills for the design-supported subset of types.
      %w[written multiple_choice calculation markdown].each do |t|
        expect(page).to have_css(%([data-part-type-pill="#{t}"]))
      end
    end
  end

  it 'changes a part type via the rail and the paper morphs in place' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    page.find('[data-part-index="0"] .composite__label').click

    # Part (a) is currently 'written'. Clicking the multiple_choice pill
    # must surface the yellow-banner warning before any PATCH fires.
    page.find('[data-part-type-pill="multiple_choice"]').click

    expect(page).to have_css('[data-rail-part-inspector-target="warningBanner"]', wait: 3)
    within('[data-rail-part-inspector-target="warningBanner"]') do
      expect(page).to have_text(/switching type will reset/i)
      click_button('Confirm')
    end

    # Wait until the server-side update completes by polling the JSONB.
    Timeout.timeout(5) do
      loop do
        break if composite.reload.options['parts'][0]['type'] == 'multiple_choice'
        sleep 0.1
      end
    end

    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)
    within('[data-part-index="0"]') do
      # MCQ markup from #9's adapter — `.mc-options` is the canonical
      # answer-surface emitted by `questions/_multiple_choice` partial.
      expect(page).to have_css('.mc-options', visible: :all)
    end
  end

  it 'changes a part marks via the rail' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    page.find('[data-part-index="0"] .composite__label').click

    fill_in 'part_marks', with: '5'
    page.find('[data-rail-part-inspector-target="marks"]').send_keys(:tab)

    # Wait until the server-side update lands.
    Timeout.timeout(5) do
      loop do
        break if composite.reload.options['parts'][0]['marks'].to_i == 5
        sleep 0.1
      end
    end

    expect(composite.reload.options['parts'][0]['marks'].to_i).to eq(5)
  end

  it 'changes answer_size via the rail' do
    visit edit_question_path(composite)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    page.find('[data-part-index="0"] .composite__label').click

    select 'Long', from: 'part_answer_size'

    Timeout.timeout(5) do
      loop do
        break if composite.reload.options['parts'][0]['answer_size'] == 'long'
        sleep 0.1
      end
    end

    expect(composite.reload.options['parts'][0]['answer_size']).to eq('long')
  end
end
