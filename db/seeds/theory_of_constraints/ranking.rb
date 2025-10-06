# frozen_string_literal: true

toc = Topic.find_by!(name: 'Theory of Constraints')

puts '  - TOC ranking questions...'

Question.create!(
  topic: toc,
  content: 'Rank the actions by priority when a single bottleneck is the primary constraint.',
  answer: 'Exploit > Subordinate > Elevate (initially)',
  points: 2,
  answer_size: 'short',
  question_type: 'ranking',
  options: ['Elevate', 'Exploit', 'Subordinate']
)

