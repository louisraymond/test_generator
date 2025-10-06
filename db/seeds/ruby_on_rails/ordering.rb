# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')

puts '  - Rails ordering questions...'

Question.create!(
  topic: programming,
  content: 'Place the Rails request lifecycle steps in order.',
  answer: 'Router → Controller → View → Response',
  points: 2,
  answer_size: 'short',
  question_type: 'ordering',
  options: ['Controller', 'View', 'Router', 'Response']
)

