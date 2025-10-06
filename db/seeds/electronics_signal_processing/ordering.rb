# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')

puts '  - Electronics ordering questions...'

Question.create!(
  topic: electronics,
  content: 'Order these EM spectrum bands from lowest to highest frequency.',
  answer: 'Radio → Microwave → Infrared → Visible',
  points: 2,
  answer_size: 'short',
  question_type: 'ordering',
  options: ['Visible', 'Infrared', 'Microwave', 'Radio']
)

