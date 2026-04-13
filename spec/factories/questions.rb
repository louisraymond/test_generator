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
  end
end
