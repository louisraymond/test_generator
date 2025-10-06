# frozen_string_literal: true

physics = Topic.find_by!(name: 'Physics - MOSFETs & Circuits')

puts '  - Physics multiple choice...'

Question.create!(
  topic: physics,
  content: 'Which of the following best describes spaced repetition in learning?',
  answer: 'B - Reviewing material at increasing intervals over time.',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Studying material once intensively before an exam', 'correct' => false },
    { 'text' => 'Reviewing material at increasing intervals over time', 'correct' => true },
    { 'text' => 'Reading material multiple times in one session', 'correct' => false },
    { 'text' => 'Creating summary notes from textbooks', 'correct' => false }
  ]
)

Question.create!(
  topic: physics,
  content: 'What does the symbol Ω represent?',
  answer: 'A - Ohms, the unit of electrical resistance',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Ohms', 'correct' => true },
    { 'text' => 'Webers', 'correct' => false },
    { 'text' => 'Siemens', 'correct' => false },
    { 'text' => 'Tesla', 'correct' => false }
  ]
)

