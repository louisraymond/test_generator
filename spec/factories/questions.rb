FactoryBot.define do
  factory :question do
    association :topic
    association :source
    sequence(:content) { |n| "Question content #{n}?" }
    sequence(:answer) { |n| "Answer #{n}" }
    points { 2 }
    answer_size { 'short' }
    question_type { 'written' }
    options { [] }
    source_reference { 'Ref-1' }
    answer_label { 'answer' }
    unit { nil }

    trait :multiple_choice do
      question_type { 'multiple_choice' }
      options { [{ 'text' => 'Option A', 'correct' => true }, { 'text' => 'Option B', 'correct' => false }] }
    end

    trait :ranking do
      question_type { 'ranking' }
      options { [{ 'text' => 'First', 'rank' => 1 }, { 'text' => 'Second', 'rank' => 2 }] }
    end

    trait :calculation do
      question_type { 'calculation' }
      answer_label { 'result' }
      unit { 'm/s' }
    end

    trait :matching do
      question_type { 'matching' }
      options { { 'left' => %w[A B], 'right' => %w[1 2] } }
    end

    trait :with_module do
      association :topic_module
    end

    # Legacy composite trait — backed by `options['parts']` jsonb only.
    # Kept for backward compatibility with specs that haven't been
    # migrated yet. New specs should use `:composite_with_ar_parts`
    # because AR rows are now the source of truth (Editor #11).
    trait :composite do
      question_type { 'composite' }
      content { 'Parent stem.' }
      answer  { 'Parent answer.' }
      points  { 6 }
      options do
        {
          'parts' => [
            { 'stem' => 'Part A.', 'type' => 'written',     'marks' => 2, 'answer_size' => 'medium' },
            { 'stem' => 'Part B.', 'type' => 'calculation', 'marks' => 3, 'answer_label' => 'x', 'unit' => 'm' },
          ],
        }
      end
    end

    # Editor #11 — AR-backed composite. Mirrors the legacy `:composite`
    # part shape but persists the parts as `QuestionPart` rows so it
    # exercises the new source of truth. Use this trait in any spec
    # written after the migration.
    trait :composite_with_ar_parts do
      question_type { 'composite' }
      content { 'Parent stem.' }
      answer  { 'Parent answer.' }
      points  { 6 }
      options { {} } # no jsonb parts — AR is authoritative

      after(:create) do |question, _evaluator|
        question.question_parts.create!(
          position: 1, part_type: 'written', marks: 2,
          stem: 'Part A.', options: { 'answer_size' => 'medium' }
        )
        question.question_parts.create!(
          position: 2, part_type: 'calculation', marks: 3,
          stem: 'Part B.', answer_label: 'x', unit: 'm', options: {}
        )
      end
    end
  end
end
