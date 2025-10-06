# frozen_string_literal: true

codebase = Topic.find_by!(name: 'This Codebase')
docs = Source.find_by(name: 'Project Documentation')

puts '  - Codebase written questions...'

Question.create!(
  topic: codebase,
  source: docs,
  source_reference: 'docs/app_exam.md',
  content: 'Describe the purpose of the ExamBuilder service in this application.',
  answer: 'ExamBuilder generates an exam by selecting questions from a pool based on criteria like topic distribution, difficulty, total points. It coordinates question selection logic and constructs an Exam model with associated ExamQuestions in the correct order.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: codebase,
  content: 'Explain how the question polymorphic type system works in this codebase.',
  answer: 'Questions have a question_type attribute (single table inheritance or enum). The options_text field stores serialized JSON for question‑specific data (e.g., multiple choice options, matching pairs). Rendering partials are chosen dynamically based on question_type, allowing a unified Question model to support many formats.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: codebase,
  content: 'Describe the relationship between Topics, LearningObjectives, and Questions.',
  answer: 'A Topic has_many LearningObjectives. A Question belongs_to a Topic and has_many LearningObjectives through question_learning_objectives (many‑to‑many join table). This allows each question to be tagged with multiple learning outcomes under a single topic.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

