require 'rails_helper'

# Editor ticket #9 — composite parts render by `part_type`.
#
# Design contract item 3 (`/.claude/plans/i-want-you-to-goofy-micali.md`):
# "Composite parts MUST embed the standalone per-type renderers, not
#  re-implement them — i.e. when a part has type: calculation the part's
#  body renders the calculation-paper layout, not generic ruled lines."
#
# Currently `app/views/questions/_cm_composite.html.erb` always renders the
# part's stem in CM6 but does not emit a type-specific answer surface below
# it. These specs lock in that each part renders the type-specific DOM.
RSpec.describe 'Composite parts — render by part_type', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic) }

  def build_composite(parts)
    create(:question,
           topic: topic,
           question_type: 'composite',
           content: 'Parent stem.',
           answer:  'Parent answer.',
           points:  10,
           options: { 'parts' => parts })
  end

  it 'renders a calculation part with the calculation-paper layout' do
    q = build_composite([
      { 'stem' => 'Compute X.', 'type' => 'calculation', 'marks' => 2,
        'answer_label' => 'X', 'unit' => 'm' },
      { 'stem' => 'Side note.', 'type' => 'written',     'marks' => 1,
        'answer_size' => 'short' },
    ])

    visit edit_question_path(q)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    within('[data-part-index="0"]') do
      # Calculation paper layout: working room + final-answer line.
      expect(page).to have_css('.answer-box',          visible: :all)
      expect(page).to have_css('.final-answer',        visible: :all)
      expect(page).to have_css('.final-answer-line',   visible: :all)
      expect(page).to have_css('.final-answer-label',  text: /X\s*=/, visible: :all)
      expect(page).to have_css('.final-answer-unit',   text: 'm',     visible: :all)
    end
  end

  it 'renders a multiple_choice part with an MCQ option list' do
    q = build_composite([
      { 'stem' => 'Pick one.', 'type' => 'multiple_choice', 'marks' => 1,
        'options' => [
          { 'text' => 'Option A', 'correct' => true },
          { 'text' => 'Option B', 'correct' => false },
        ] },
    ])

    visit edit_question_path(q)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    within('[data-part-index="0"]') do
      expect(page).to have_css('.mc-options', visible: :all)
      expect(page).to have_css('.mc-option',  count: 2, visible: :all)
      expect(page).to have_css('.mc-checkbox', count: 2, visible: :all)
      expect(page).to have_text('Option A')
      expect(page).to have_text('Option B')
    end
  end

  it 'renders a written part with ruled answer lines sized by answer_size' do
    q = build_composite([
      { 'stem' => 'Discuss.', 'type' => 'written', 'marks' => 4,
        'answer_size' => 'medium' },
    ])

    visit edit_question_path(q)
    expect(page).to have_css('[data-part-index="0"]', wait: 5)

    within('[data-part-index="0"]') do
      expect(page).to have_css('.answer-lines',          visible: :all)
      expect(page).to have_css('.answer-lines-medium',   visible: :all)
    end
  end

  it 'renders a composite with three different part types each with their own answer surface' do
    q = build_composite([
      { 'stem' => 'Compute.',  'type' => 'calculation',     'marks' => 2,
        'answer_label' => 'y', 'unit' => 'kg' },
      { 'stem' => 'Pick one.', 'type' => 'multiple_choice', 'marks' => 1,
        'options' => [{ 'text' => 'A', 'correct' => true }, { 'text' => 'B' }] },
      { 'stem' => 'Discuss.',  'type' => 'written',         'marks' => 3,
        'answer_size' => 'long' },
    ])

    visit edit_question_path(q)
    expect(page).to have_css('[data-part-index="2"]', wait: 5)

    within('[data-part-index="0"]') do
      expect(page).to have_css('.final-answer-line', visible: :all)
    end
    within('[data-part-index="1"]') do
      expect(page).to have_css('.mc-options', visible: :all)
    end
    within('[data-part-index="2"]') do
      expect(page).to have_css('.answer-lines.answer-lines-long', visible: :all)
    end
  end
end
