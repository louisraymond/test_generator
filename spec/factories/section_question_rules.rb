FactoryBot.define do
  factory :section_question_rule do
    association :exam_section
    association :question
    rule_type { 'force_include' }
    repeat_count { 1 }
  end
end
