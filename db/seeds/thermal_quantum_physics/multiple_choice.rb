# frozen_string_literal: true

thermal = Topic.find_by!(name: 'Introduction to Thermal & Quantum Physics')

puts '  - Thermal & Quantum multiple choice...'

Question.create!(
  topic: thermal,
  content: 'Which constant relates energy and frequency for a photon?',
  answer: 'B - Planck constant (h)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Boltzmann constant (k)', 'correct' => false },
    { 'text' => 'Planck constant (h)', 'correct' => true },
    { 'text' => 'Gas constant (R)', 'correct' => false },
    { 'text' => 'Speed of light (c)', 'correct' => false }
  ]
)

Question.create!(
  topic: thermal,
  content: 'What does the second law of thermodynamics state?',
  answer: 'C - Entropy of an isolated system always increases.',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Energy is conserved', 'correct' => false },
    { 'text' => 'Temperature always equalizes', 'correct' => false },
    { 'text' => 'Entropy of an isolated system always increases', 'correct' => true },
    { 'text' => 'Heat flows from cold to hot', 'correct' => false }
  ]
)

