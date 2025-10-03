FactoryBot.define do
  factory :exam do
    sequence(:title) { |n| "Exam #{n}" }
  end
end
