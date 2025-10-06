# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')

puts '  - Rails composite questions...'

Question.create!(
  topic: programming,
  content: 'Rails fundamentals composite question.',
  answer: 'a) MVC responsibilities; b) Strong params; c) id param',
  points: 5,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Briefly describe MVC in Rails.', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What are strong parameters used for?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'multiple_choice', 'content' => 'c) Which key holds the resource id by convention?', 'options' => ['id', 'uuid', 'key'], 'points' => 1 }
    ]
  }
)

