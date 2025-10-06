# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')

puts '  - Electronics multiple choice...'

Question.create!(
  topic: electronics,
  content: 'What is the primary advantage of frequency modulation (FM) over amplitude modulation (AM)?',
  answer: 'C - Better immunity to noise and interference.',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Requires less bandwidth', 'correct' => false },
    { 'text' => 'Simpler circuit design', 'correct' => false },
    { 'text' => 'Better immunity to noise and interference', 'correct' => true },
    { 'text' => 'Lower transmission power requirements', 'correct' => false }
  ]
)

Question.create!(
  topic: electronics,
  content: 'Which component primarily stores energy in a magnetic field?',
  answer: 'B - Inductor',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Resistor', 'correct' => false },
    { 'text' => 'Inductor', 'correct' => true },
    { 'text' => 'Capacitor', 'correct' => false },
    { 'text' => 'Diode', 'correct' => false }
  ]
)

