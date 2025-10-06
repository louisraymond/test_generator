# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')
commons = Source.find_by(name: 'Wikimedia Commons')

puts '  - Electronics image occlusion...'

Question.create!(
  topic: electronics,
  content: 'Identify the hidden component in the circuit diagram.',
  answer: 'Operational amplifier (op‑amp)',
  points: 2,
  answer_size: 'short',
  question_type: 'image_occlusion',
  options: { 'image' => 'placeholder.svg', 'masks' => [ { 'x' => 35, 'y' => 30, 'w' => 25, 'h' => 15 } ] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:RC_lowpass_filter.svg',
  content: 'In the RC low-pass diagram, which components are occluded? (1 and 2)',
  answer: '1. Capacitor (C); 2. Resistor (R).',
  points: 2,
  answer_size: 'short',
  question_type: 'image_occlusion',
  options: { 'image' => 'RC_lowpass_filter.svg', 'masks' => [ { 'x' => 35, 'y' => 60, 'w' => 12, 'h' => 12 }, { 'x' => 63, 'y' => 23, 'w' => 10, 'h' => 18 } ] }
)

