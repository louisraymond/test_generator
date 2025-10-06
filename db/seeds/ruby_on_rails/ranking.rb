# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')

puts '  - Rails ranking questions...'

Question.create!(
  topic: programming,
  content: 'Rank caching layers by typical hit speed (fastest → slowest).',
  answer: 'In‑memory → Redis → Database',
  points: 2,
  answer_size: 'short',
  question_type: 'ranking',
  options: ['Database', 'In-memory', 'Redis']
)

