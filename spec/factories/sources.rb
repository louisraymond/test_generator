FactoryBot.define do
  factory :source do
    sequence(:name) { |n| "Source #{n}" }
    source_type { 'book' }
    notes { 'Important reference text' }
  end
end
