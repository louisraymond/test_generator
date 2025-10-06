# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')

puts '  - Electronics matching questions...'

Question.create!(
  topic: electronics,
  content: 'Match each unit with its physical quantity.',
  answer: "Ohm → Resistance; Farad → Capacitance; Henry → Inductance",
  points: 3,
  answer_size: 'short',
  question_type: 'matching',
  options: {
    'left' => ['Ohm (Ω)', 'Farad (F)', 'Henry (H)'],
    'right' => ['Inductance', 'Resistance', 'Capacitance']
  }
)

