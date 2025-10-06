# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')
rails_guides = Source.find_by(name: 'Rails Guides')

puts '  - Rails multiple choice...'

Question.create!(
  topic: programming,
  source: rails_guides,
  content: 'In Rails, which method would you use to find a record by its primary key, raising an exception if not found?',
  answer: 'C - Model.find(id)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Model.where(id: id).first', 'correct' => false },
    { 'text' => 'Model.find_by(id: id)', 'correct' => false },
    { 'text' => 'Model.find(id)', 'correct' => true },
    { 'text' => 'Model.get(id)', 'correct' => false }
  ]
)

