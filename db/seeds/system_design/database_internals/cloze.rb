# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
database_internals = system_design.topic_modules.find_by!(name: 'Database Internals & Indexing')

puts '  - System Design cloze questions...'

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Data that remains available even after a system restart is said to be [[persistent]].',
  answer: 'persistent',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'RAM is considered [[volatile]] memory because it loses its contents when power is turned off.',
  answer: 'volatile',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Hard drives are preferred for long-term data storage because they are [[non-volatile]].',
  answer: 'non-volatile',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The physical disk that stores data in a traditional hard drive is called a [[platter]].',
  answer: 'platter',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The moving component that reads and writes data on a disk is the [[arm]].',
  answer: 'arm',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The time taken for the hard-drive arm to move to the correct disk location is known as [[seek]] time.',
  answer: 'seek',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Reading data stored close together on a disk is faster because it reduces [[arm]] movement.',
  answer: 'arm',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A [[full]] table scan means checking every row in a table one by one.',
  answer: 'full',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A database that must check every row to find a match has a time complexity of [[$O(n)$]].',
  answer: 'O(n)',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Updating a record requires finding it first, so its write time complexity is also [[$O(n)$]].',
  answer: 'O(n)',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'In an [[append]]-only design, instead of overwriting data, new versions are added to the end of the file.',
  answer: 'append',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Appending data to the end of a table makes write performance approximately $O([[1]])$.',
  answer: '1',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Because append-only tables grow with every update, read performance may get [[slower]] over time.',
  answer: 'slower',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Improving write speed by appending usually causes [[worse]] read performance.',
  answer: 'worse',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The trade-off between read and write performance means optimizing one often makes the other [[slower]].',
  answer: 'slower',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A data structure that accelerates lookups by avoiding full-table scans is called an [[index]].',
  answer: 'index',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'An index improves read speed but makes [[write]] operations slower because it must be updated too.',
  answer: 'write',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'An index that covers more than one field is called a [[composite]] index.',
  answer: 'composite',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A query that asks for all rows between two values is called a [[range]] query.',
  answer: 'range',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Range queries work well with [[ordered]] data structures like B-trees.',
  answer: 'ordered',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Hash indexes are not ideal for range queries because they do not preserve [[order]] of keys.',
  answer: 'order',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The Big-O notation $O(n)$ describes performance that grows [[linearly]] with data size.',
  answer: 'linearly',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'On hard drives, reading scattered data is slower due to extra [[seeks]] and [[rotations]].',
  answer: 'seeks; rotations',
  points: 2,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Systems like Facebook prioritize fast [[read]] operations because they are performed most frequently.',
  answer: 'read',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A database designer must balance read speed, write speed, and [[persistence]] to achieve good performance.',
  answer: 'persistence',
  points: 1,
  answer_size: 'short',
  question_type: 'cloze'
)

puts "  ✓ Created 25 System Design cloze questions"

