FactoryBot.define do
  factory :section_source_rule do
    association :exam_section
    source_type { 'Topic' }
    source_id { 1 }
    weight { 1 }
  end
end
