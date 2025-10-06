# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')

puts '  - Rails matching questions...'

Question.create!(
  topic: programming,
  content: 'Match each Rails component to its responsibility.',
  answer: "Controller → Coordinates request flow; Model → Business/data logic; View → Presentation",
  points: 3,
  answer_size: 'short',
  question_type: 'matching',
  options: {
    'left' => ['Controller', 'Model', 'View'],
    'right' => ['Presentation', 'Business/data logic', 'Coordinates request flow']
  }
)

