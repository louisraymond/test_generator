FactoryBot.define do
  factory :topic_module do
    association :topic
    sequence(:name) { |n| "Module #{n}" }
    sequence(:position) { |n| n - 1 }
  end
end
