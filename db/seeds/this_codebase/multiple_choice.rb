# frozen_string_literal: true

codebase = Topic.find_by!(name: 'This Codebase')
docs = Source.find_by(name: 'Project Documentation')

puts '  - Codebase multiple choice...'

Question.create!(
  topic: codebase,
  source: docs,
  content: 'Which Rails helper is used in this app to embed SVG images inline?',
  answer: 'B - embed_svg',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'image_tag', 'correct' => false },
    { 'text' => 'embed_svg', 'correct' => true },
    { 'text' => 'inline_svg', 'correct' => false },
    { 'text' => 'svg_tag', 'correct' => false }
  ]
)

Question.create!(
  topic: codebase,
  content: 'Which gem does this app use to generate PDF exams?',
  answer: 'C - Grover',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Prawn', 'correct' => false },
    { 'text' => 'WickedPDF', 'correct' => false },
    { 'text' => 'Grover', 'correct' => true },
    { 'text' => 'PDFKit', 'correct' => false }
  ]
)

