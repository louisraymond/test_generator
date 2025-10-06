# frozen_string_literal: true

toc = Topic.find_by!(name: 'Theory of Constraints')

puts '  - TOC cloze questions...'

Question.create!(
  topic: toc,
  content: 'The Five Focusing Steps begin with [[identify]] the constraint and end with [[repeat]].',
  answer: 'identify; repeat',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

