FactoryBot.define do
  factory :question_learning_objective do
    association :question
    association :learning_objective
  end
end
