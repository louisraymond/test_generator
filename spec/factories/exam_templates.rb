FactoryBot.define do
  factory :exam_template do
    sequence(:name) { |n| "Template #{n}" }
    description { "A test exam template" }
    duration_minutes { 60 }
    use_count { 0 }
  end
end
