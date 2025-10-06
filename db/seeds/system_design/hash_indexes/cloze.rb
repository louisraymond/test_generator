# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
hash_indexes = system_design.topic_modules.find_by!(name: 'Hash Indexes')

puts '    - Hash Indexes cloze questions...'

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'A [[hash function]] takes an input and always returns the same [[numeric]] output for that input.',
  answer: 'hash function; numeric',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash maps achieve [[$O(1)$]] time complexity for both reads and writes.',
  answer: 'O(1)',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'A [[collision]] occurs when two different keys hash to the same array index.',
  answer: 'collision',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: '[[Chaining]] is a collision resolution method that uses a linked list at each array index.',
  answer: 'Chaining',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: '[[Probing]] is a collision resolution method that looks for the next available spot in the array.',
  answer: 'Probing',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash indexes are typically kept in [[RAM]] because random access is fast there.',
  answer: 'RAM',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash maps perform poorly on [[disk]] because elements are scattered, requiring many random seeks.',
  answer: 'disk',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'RAM is [[volatile]], meaning data is lost when power is turned off.',
  answer: 'volatile',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'A [[write-ahead log]] provides durability for hash indexes by recording all operations on disk.',
  answer: 'write-ahead log',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'The write-ahead log can [[replay]] all operations to rebuild the hash index after a crash.',
  answer: 'replay',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Write-ahead logs use [[sequential]] writes, which are faster than random writes on disk.',
  answer: 'sequential',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash functions [[destroy]] the ordering of keys, making range queries impossible.',
  answer: 'destroy',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'To find all names between A and B with a hash index, you would need to check [[infinite]] possible strings or perform an [[$O(n)$]] scan.',
  answer: 'infinite; O(n)',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash indexes must fit in [[RAM]], which is expensive and limits their size.',
  answer: 'RAM',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Binary search trees provide [[$O(\log n)$]] reads and writes but can handle range queries.',
  answer: 'O(log n)',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Hash indexes are ideal for [[small]] datasets where [[range queries]] are not needed.',
  answer: 'small; range queries',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Good use cases for hash indexes include [[session storage]], [[caching layers]], or small lookup tables.',
  answer: 'session storage; caching layers',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'The acronym RAM stands for [[Random Access Memory]].',
  answer: 'Random Access Memory',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

puts "    ✓ Created 18 Hash Indexes cloze questions"

