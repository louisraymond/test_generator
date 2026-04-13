FactoryBot.define do
  factory :topic do
    sequence(:name) { |n| "Topic #{n}" }
    module_aims { ["Understand core concepts"] }
    learning_outcomes { [{ 'title' => 'Knowledge', 'items' => ['Describe key principles'] }] }
    syllabus_outline { [{ 'title' => 'Unit 1', 'items' => ['Introduction'] }] }
    reference_links { ["textbook ch.1"] }

    trait :with_modules do
      after(:create) do |topic|
        create(:topic_module, topic: topic, name: 'Module A', position: 0)
        create(:topic_module, topic: topic, name: 'Module B', position: 1)
      end
    end
  end
end
