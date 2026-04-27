# frozen_string_literal: true

require 'rails_helper'

# Editor #9 / design contract item 3 — locked as a real invariant.
#
# "Composite parts MUST embed the standalone per-type renderers, not
#  re-implement them."
#
# Approach (c) in the plan: each composite part's answer surface is rendered
# by passing a `CompositePartAdapter` (which quacks like a Question) into the
# existing standalone per-type partial. This spec asserts that the DOM the
# composite branch emits for one part is byte-identical to the DOM the
# standalone partial emits for the equivalent Question.
#
# If anyone reaches for a copy-paste fork of the per-type DOM in
# `_cm_composite.html.erb`, this spec will fail and force them to keep
# parity (or update the standalone partial too).
RSpec.describe 'composite parts parity with standalone per-type partials', type: :view do
  include QuestionTypesHelper

  describe 'multiple_choice' do
    let(:options) do
      [{ 'text' => 'Option Alpha', 'correct' => true },
       { 'text' => 'Option Beta',  'correct' => false }]
    end

    it 'composite-part DOM matches standalone-MCQ DOM for the same options' do
      standalone_q = build_stubbed(:question,
                                   question_type: 'multiple_choice',
                                   options: options)
      part_q = composite_part_question(
        build_stubbed(:question, id: 42),
        { 'type' => 'multiple_choice', 'options' => options },
        0
      )

      standalone = render(partial: 'questions/multiple_choice', locals: { question: standalone_q })
      part_dom   = render(partial: 'questions/multiple_choice', locals: { question: part_q })

      expect(part_dom).to eq(standalone)
    end
  end

  describe 'calculation' do
    it 'composite-part DOM matches standalone-calculation DOM for the same answer_label/unit' do
      standalone_q = build_stubbed(:question,
                                   question_type: 'calculation',
                                   answer_label: 'velocity',
                                   unit: 'm/s')
      part_q = composite_part_question(
        build_stubbed(:question, id: 42),
        { 'type' => 'calculation', 'answer_label' => 'velocity', 'unit' => 'm/s' },
        0
      )

      standalone = render(partial: 'questions/calculation', locals: { question: standalone_q })
      part_dom   = render(partial: 'questions/calculation', locals: { question: part_q })

      expect(part_dom).to eq(standalone)
    end
  end
end
