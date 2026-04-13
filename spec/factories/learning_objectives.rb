FactoryBot.define do
  factory :learning_objective do
    association :topic
    sequence(:category) { |n| "Category #{n}" }
    category_order { 0 }
    sequence(:position) { |n| n - 1 }
    sequence(:description) { |n| "Learning objective description #{n}" }

    trait :with_module do
      association :topic_module
    end
  end
end
