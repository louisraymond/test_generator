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
  end
end
