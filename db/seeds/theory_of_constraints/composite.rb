# frozen_string_literal: true

toc = Topic.find_by!(name: 'Theory of Constraints')

puts '  - TOC composite questions...'

Question.create!(
  topic: toc,
  content: 'Answer the following about TOC.',
  answer: 'a) Definition of constraint; b) Step 2 is Exploit; c) Example bottleneck: heat‑treating oven',
  points: 5,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Define a constraint.', 'answer_size' => 'short', 'points' => 1 },
      { 'type' => 'multiple_choice', 'content' => 'b) What is step 2 of the Five Focusing Steps?', 'options' => ['Identify', 'Exploit', 'Elevate'], 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Give one example of a typical manufacturing bottleneck.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

