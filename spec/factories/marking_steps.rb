FactoryBot.define do
  factory :marking_step do
    association :question
    kind { 'm' }
    n { 1 }
    sequence(:text) { |i| "Step #{i}: show working" }
    accepts { [] }
    rejects { [] }
  end
end
