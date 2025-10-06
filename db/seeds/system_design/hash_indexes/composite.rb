# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
hash_indexes = system_design.topic_modules.find_by!(name: 'Hash Indexes')

puts '    - Hash Indexes composite questions...'

# Block A – Hash Functions & Hash Maps

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about hash functions and hash maps.',
  answer: 'a) Function that always returns same output for same input; b) O(1); c) O(1); d) Direct array indexing; e) Collision',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is a hash function?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is the time complexity of hash map reads?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What is the time complexity of hash map writes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why do hash maps achieve constant time operations?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What is it called when two keys hash to the same index?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block B – Collision Resolution

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about hash collision resolution methods.',
  answer: 'a) When two keys hash to same index; b) Chaining; c) Linked list; d) Probing; e) Next available spot',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) When does a hash collision occur?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is the name of the method that uses linked lists for collisions?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) In chaining, what data structure is stored at each array index?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What is the name of the method that looks for the next available spot?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) In probing, where is a colliding element placed?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block C – Hash Index Structure

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about how hash indexes work.',
  answer: 'a) Hash map; b) Indexed field value; c) Disk location or row; d) O(1) instead of O(n); e) Eliminates full table scan',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What data structure does a hash index use?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What does the key in a hash index represent?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What does the value in a hash index represent?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What time complexity does a hash index provide for lookups?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What problem does a hash index solve?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block D – Memory vs Disk

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about why hash indexes are kept in RAM.',
  answer: 'a) RAM; b) Elements scattered requiring random seeks; c) Allows fast random access; d) Expensive; e) Must fit in RAM',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Where are hash indexes typically stored?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why do hash maps perform poorly on disk?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why is RAM good for hash maps?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What is a disadvantage of RAM?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What size constraint does this create for hash indexes?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block E – Durability & Write-Ahead Log

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about durability in hash indexes.',
  answer: 'a) Volatile - loses data on shutdown; b) Write-ahead log; c) On disk; d) Replaying all operations; e) Sequential nature',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What problem does RAM have for durability?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What mechanism provides durability for hash indexes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Where is the write-ahead log stored?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How is a hash index rebuilt after a crash?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why are write-ahead log writes relatively fast?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block F – Sequential vs Random I/O

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about disk I/O patterns.',
  answer: 'a) Data in adjacent locations; b) Minimal disk arm movement; c) Data in scattered locations; d) Many disk seeks; e) Sequential',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What are sequential writes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why are sequential writes fast on disk?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What are random writes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why are random writes slow on disk?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What type of writes does a write-ahead log use?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block G – Range Query Limitations

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about range queries and hash indexes.',
  answer: 'a) No; b) Destroys ordering; c) Check infinite strings or O(n) scan; d) O(n); e) Not feasible',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Can hash indexes efficiently handle range queries?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What does a hash function do to key ordering?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What would be required to find names between A and B?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What time complexity results from scanning all indexes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Is this approach feasible for range queries?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block H – Comparison with Other Indexes

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions comparing hash indexes with other index types.',
  answer: 'a) O(log n); b) Yes; c) O(1) vs O(log n); d) Cannot do range queries; e) B-tree',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is the time complexity of reads in a binary search tree?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Can binary search trees handle range queries?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) How do hash index lookup times compare to B-trees?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What is the main limitation of hash indexes vs B-trees?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Which index type is more versatile?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block I – Use Cases & Trade-offs

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about when to use hash indexes.',
  answer: 'a) Small dataset; b) Single-key lookups; c) No range queries; d) O(1) performance; e) Session storage/caching',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What size dataset works best with hash indexes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What type of queries are hash indexes optimized for?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What query pattern should be avoided?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What performance benefit justifies using hash indexes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Give an example use case for hash indexes.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block J – Constraints & Requirements

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Answer the following questions about hash index constraints.',
  answer: 'a) Must fit in RAM; b) RAM is expensive and limited; c) Write-ahead log; d) Slows writes; e) Memory cost, durability overhead, no ranges',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is the main size constraint for hash indexes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why is this constraint significant?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What additional component is needed for durability?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How does durability affect performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) List three main trade-offs of hash indexes.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

puts "    ✓ Created 10 Hash Indexes composite questions"

