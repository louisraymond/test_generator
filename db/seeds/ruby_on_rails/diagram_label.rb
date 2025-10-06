# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')

puts '  - Rails diagram labeling...'

Question.create!(
  topic: programming,
  content: 'Label MVC on the Rails architecture diagram.',
  answer: 'Model, View, Controller',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'placeholder.svg', 'labels' => ['Model', 'View', 'Controller'] }
)

