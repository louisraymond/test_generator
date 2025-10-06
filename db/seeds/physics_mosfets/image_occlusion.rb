# frozen_string_literal: true

physics = Topic.find_by!(name: 'Physics - MOSFETs & Circuits')

puts '  - Physics image occlusion...'

Question.create!(
  topic: physics,
  content: 'Identify the hidden label on the transistor symbol.',
  answer: 'Gate (for MOSFET diagram)',
  points: 2,
  answer_size: 'short',
  question_type: 'image_occlusion',
  options: { 'image' => 'placeholder.svg', 'masks' => [ { 'x' => 20, 'y' => 55, 'w' => 20, 'h' => 12 } ] }
)

