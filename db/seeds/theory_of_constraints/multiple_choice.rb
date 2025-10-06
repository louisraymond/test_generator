# frozen_string_literal: true

toc = Topic.find_by!(name: 'Theory of Constraints')

puts '  - TOC multiple choice...'

Question.create!(
  topic: toc,
  content: 'Which of the following best describes the goal of the Theory of Constraints?',
  answer: 'B - To maximize throughput while minimizing inventory and operating expense.',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'To minimize costs across all departments equally', 'correct' => false },
    { 'text' => 'To maximize throughput while minimizing inventory and operating expense', 'correct' => true },
    { 'text' => 'To achieve 100% utilization of all resources', 'correct' => false },
    { 'text' => 'To reduce cycle time at non-constraint resources', 'correct' => false }
  ]
)

