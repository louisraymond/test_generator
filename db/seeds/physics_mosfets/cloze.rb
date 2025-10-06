# frozen_string_literal: true

physics = Topic.find_by!(name: 'Physics - MOSFETs & Circuits')

puts '  - Physics cloze questions...'

Question.create!(
  topic: physics,
  content: 'In a MOSFET, the gate is [[insulated]] from the channel by a thin layer of [[oxide]].',
  answer: 'insulated; oxide',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

