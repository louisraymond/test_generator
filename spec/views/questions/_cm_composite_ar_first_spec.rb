# frozen_string_literal: true

require 'rails_helper'

# Editor #50 — _cm_composite.html.erb must read parts from QuestionPart
# AR rows when they exist, falling back to options['parts'] jsonb only
# when AR is empty. Asserted with the divergence case: AR says one
# thing, jsonb says another. AR must win.
RSpec.describe 'questions/_cm_composite.html.erb AR-first read', type: :view do
  let(:topic) { create(:topic) }

  it 'renders QuestionPart AR rows in preference to stale options.parts jsonb' do
    composite = topic.questions.create!(
      question_type: 'composite',
      content: 'Parent stem.',
      answer: 'Parent answer.',
      points: 1,
      options: { 'parts' => [
        { 'stem' => 'STALE jsonb stem A', 'type' => 'written', 'marks' => 1 },
        { 'stem' => 'STALE jsonb stem B', 'type' => 'written', 'marks' => 2 },
      ] },
    )
    composite.question_parts.create!(position: 1, stem: 'AR canonical stem A',
                                     part_type: 'written', marks: 1)
    composite.question_parts.create!(position: 2, stem: 'AR canonical stem B',
                                     part_type: 'written', marks: 2)

    rendered = render(partial: 'questions/cm_composite',
                      locals: { question: composite.reload })

    expect(rendered).to include('AR canonical stem A')
    expect(rendered).to include('AR canonical stem B')
    expect(rendered).not_to include('STALE jsonb stem A')
    expect(rendered).not_to include('STALE jsonb stem B')
  end

  it 'falls back to options.parts jsonb when no AR rows exist' do
    composite = topic.questions.create!(
      question_type: 'composite',
      content: 'Parent stem.',
      answer: 'Parent answer.',
      points: 1,
      options: { 'parts' => [
        { 'stem' => 'jsonb fallback stem', 'type' => 'written', 'marks' => 1 },
      ] },
    )

    rendered = render(partial: 'questions/cm_composite',
                      locals: { question: composite })

    expect(rendered).to include('jsonb fallback stem')
  end
end
