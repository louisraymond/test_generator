# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')

puts '  - Electronics calculations...'

Question.create!(
  topic: electronics,
  content: 'A 10 kΩ resistor carries a current of 2 mA. Calculate the voltage across it.',
  answer: 'V = IR = 0.002 × 10,000 = 20 V',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'V',
  unit: 'V'
)

