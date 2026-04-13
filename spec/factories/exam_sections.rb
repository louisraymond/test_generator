FactoryBot.define do
  factory :exam_section do
    association :exam_template
    sequence(:name) { |n| "Section #{n}" }
    sequence(:position) { |n| n - 1 }
    question_count { 5 }
    duration_minutes { 30 }
  end
end
