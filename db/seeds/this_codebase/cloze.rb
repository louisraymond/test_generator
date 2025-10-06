# frozen_string_literal: true

codebase = Topic.find_by!(name: 'This Codebase')

puts '  - Codebase cloze questions...'

Question.create!(
  topic: codebase,
  content: 'In this codebase, the [[ExamBuilder]] service generates exams and [[Grover]] converts HTML to PDF.',
  answer: 'ExamBuilder; Grover',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

