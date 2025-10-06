# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
hash_indexes = system_design.topic_modules.find_by!(name: 'Hash Indexes')

puts '    - Hash Indexes multiple choice questions...'

# Hash Function Basics

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the key property of a hash function?',
  answer: 'B - It always returns the same output for the same input',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It returns random outputs', 'correct' => false },
    { 'text' => 'It always returns the same output for the same input', 'correct' => true },
    { 'text' => 'It preserves ordering of inputs', 'correct' => false },
    { 'text' => 'It compresses data', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does a hash function typically output?',
  answer: 'A - A number',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'A number', 'correct' => true },
    { 'text' => 'A string', 'correct' => false },
    { 'text' => 'A boolean', 'correct' => false },
    { 'text' => 'An object', 'correct' => false }
  ]
)

# Hash Map Operations

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the time complexity of reads in a hash map?',
  answer: 'A - $O(1)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => true },
    { 'text' => '$O(\log n)$', 'correct' => false },
    { 'text' => '$O(n)$', 'correct' => false },
    { 'text' => '$O(n^2)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the time complexity of writes in a hash map?',
  answer: 'A - $O(1)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => true },
    { 'text' => '$O(\log n)$', 'correct' => false },
    { 'text' => '$O(n)$', 'correct' => false },
    { 'text' => '$O(n \log n)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is a hash collision?',
  answer: 'C - When two different keys hash to the same index',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'When a hash function fails', 'correct' => false },
    { 'text' => 'When the hash map runs out of space', 'correct' => false },
    { 'text' => 'When two different keys hash to the same index', 'correct' => true },
    { 'text' => 'When a key is deleted', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Which collision resolution method uses a linked list at each array index?',
  answer: 'B - Chaining',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Probing', 'correct' => false },
    { 'text' => 'Chaining', 'correct' => true },
    { 'text' => 'Rehashing', 'correct' => false },
    { 'text' => 'Bucketing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Which collision resolution method looks for the next available spot in the array?',
  answer: 'A - Probing',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Probing', 'correct' => true },
    { 'text' => 'Chaining', 'correct' => false },
    { 'text' => 'Rehashing', 'correct' => false },
    { 'text' => 'Double hashing', 'correct' => false }
  ]
)

# Hash Index Implementation

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'In a hash index, what does the key in the hash map typically represent?',
  answer: 'A - The indexed field value (e.g., name, ID)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The indexed field value (e.g., name, ID)', 'correct' => true },
    { 'text' => 'The table name', 'correct' => false },
    { 'text' => 'The row number', 'correct' => false },
    { 'text' => 'The timestamp', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'In a hash index, what does the value in the hash map typically represent?',
  answer: 'C - The disk location of the row (or the row itself)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The hash of the key', 'correct' => false },
    { 'text' => 'The table schema', 'correct' => false },
    { 'text' => 'The disk location of the row (or the row itself)', 'correct' => true },
    { 'text' => 'The index name', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Where are hash indexes typically stored?',
  answer: 'B - In RAM (memory)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'On disk', 'correct' => false },
    { 'text' => 'In RAM (memory)', 'correct' => true },
    { 'text' => 'In cache', 'correct' => false },
    { 'text' => 'In the CPU', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why do hash maps perform poorly on disk?',
  answer: 'B - Elements are scattered, requiring many random disk seeks',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They use too much space', 'correct' => false },
    { 'text' => 'Elements are scattered, requiring many random disk seeks', 'correct' => true },
    { 'text' => 'Disk cannot store hash functions', 'correct' => false },
    { 'text' => 'They require sorting', 'correct' => false }
  ]
)

# Memory & Durability

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the main drawback of storing hash indexes in RAM?',
  answer: 'C - RAM is volatile and data is lost on shutdown',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'RAM is too slow', 'correct' => false },
    { 'text' => 'RAM cannot store hash maps', 'correct' => false },
    { 'text' => 'RAM is volatile and data is lost on shutdown', 'correct' => true },
    { 'text' => 'RAM is too fast', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does a write-ahead log (WAL) provide for a hash index?',
  answer: 'A - Durability',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Durability', 'correct' => true },
    { 'text' => 'Faster reads', 'correct' => false },
    { 'text' => 'Compression', 'correct' => false },
    { 'text' => 'Encryption', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Where is the write-ahead log stored?',
  answer: 'B - On disk',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'In RAM', 'correct' => false },
    { 'text' => 'On disk', 'correct' => true },
    { 'text' => 'In cache', 'correct' => false },
    { 'text' => 'In the CPU', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How does a write-ahead log help recover a hash index after a crash?',
  answer: 'C - By replaying all recorded operations sequentially',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'By restoring from backup', 'correct' => false },
    { 'text' => 'By reconstructing from disk', 'correct' => false },
    { 'text' => 'By replaying all recorded operations sequentially', 'correct' => true },
    { 'text' => 'By rebuilding from scratch', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why are writes to a write-ahead log relatively fast despite being on disk?',
  answer: 'A - They are sequential writes requiring minimal disk arm movement',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They are sequential writes requiring minimal disk arm movement', 'correct' => true },
    { 'text' => 'They are compressed', 'correct' => false },
    { 'text' => 'They are cached in RAM', 'correct' => false },
    { 'text' => 'They use a special fast disk', 'correct' => false }
  ]
)

# Limitations

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Can hash indexes efficiently handle range queries?',
  answer: 'B - No',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Yes', 'correct' => false },
    { 'text' => 'No', 'correct' => true },
    { 'text' => 'Only for small ranges', 'correct' => false },
    { 'text' => 'Only with special configuration', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why can\'t hash indexes do range queries efficiently?',
  answer: 'C - Hash functions destroy ordering of keys',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They are too slow', 'correct' => false },
    { 'text' => 'They use too much memory', 'correct' => false },
    { 'text' => 'Hash functions destroy ordering of keys', 'correct' => true },
    { 'text' => 'They cannot store multiple keys', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What would be required to find all names between "A" and "B" using a hash index?',
  answer: 'D - Either check infinite possible strings or scan all O(n) indexes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'One hash lookup', 'correct' => false },
    { 'text' => 'Two hash lookups', 'correct' => false },
    { 'text' => 'A binary search', 'correct' => false },
    { 'text' => 'Either check infinite possible strings or scan all O(n) indexes', 'correct' => true }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the primary constraint on hash index size?',
  answer: 'B - It must fit in RAM',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It must fit on disk', 'correct' => false },
    { 'text' => 'It must fit in RAM', 'correct' => true },
    { 'text' => 'It must fit in cache', 'correct' => false },
    { 'text' => 'No size constraint', 'correct' => false }
  ]
)

# Comparison & Use Cases

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Compared to binary search trees, hash indexes have:',
  answer: 'A - Better single-key lookup performance but no range query support',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Better single-key lookup performance but no range query support', 'correct' => true },
    { 'text' => 'Worse performance in all cases', 'correct' => false },
    { 'text' => 'Better range query support', 'correct' => false },
    { 'text' => 'The same performance', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the read time complexity for a B-tree index?',
  answer: 'B - $O(\log n)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => false },
    { 'text' => '$O(\log n)$', 'correct' => true },
    { 'text' => '$O(n)$', 'correct' => false },
    { 'text' => '$O(n \log n)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'When would a hash index be most appropriate?',
  answer: 'C - Small dataset with single-key lookups and no range queries needed',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Large dataset with many range queries', 'correct' => false },
    { 'text' => 'Any size dataset', 'correct' => false },
    { 'text' => 'Small dataset with single-key lookups and no range queries needed', 'correct' => true },
    { 'text' => 'Write-heavy workloads only', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is a good example use case for a hash index?',
  answer: 'B - Session storage or caching layer',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Time-series analytics', 'correct' => false },
    { 'text' => 'Session storage or caching layer', 'correct' => true },
    { 'text' => 'Log aggregation', 'correct' => false },
    { 'text' => 'Date range filtering', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is RAM often called due to its ability to access any location quickly?',
  answer: 'A - Random Access Memory',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Random Access Memory', 'correct' => true },
    { 'text' => 'Rapid Access Memory', 'correct' => false },
    { 'text' => 'Read Access Memory', 'correct' => false },
    { 'text' => 'Reliable Access Memory', 'correct' => false }
  ]
)

# Section A – Review & Context (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does "O(n) reads" mean in practical terms?',
  answer: 'D - Query time grows linearly with the number of rows',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Query time stays constant', 'correct' => false },
    { 'text' => 'Query time grows logarithmically', 'correct' => false },
    { 'text' => 'Query time is unpredictable', 'correct' => false },
    { 'text' => 'Query time grows linearly with the number of rows', 'correct' => true }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the key benefit of adding indexes to a database?',
  answer: 'B - Faster data access without scanning all rows',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Reduced storage space', 'correct' => false },
    { 'text' => 'Faster data access without scanning all rows', 'correct' => true },
    { 'text' => 'Automatic data backup', 'correct' => false },
    { 'text' => 'Data compression', 'correct' => false }
  ]
)

# Section B – Hash Map Fundamentals (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'In the video example, what value does the hash function return for "Jordan"?',
  answer: 'B - 4',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '0', 'correct' => false },
    { 'text' => '4', 'correct' => true },
    { 'text' => '10', 'correct' => false },
    { 'text' => '6', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the range of possible outputs for the example hash function used in the video?',
  answer: 'C - 0 to 10',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '0 to 5', 'correct' => false },
    { 'text' => '1 to 10', 'correct' => false },
    { 'text' => '0 to 10', 'correct' => true },
    { 'text' => '0 to 100', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why do we usually assume average-case constant time even when collisions exist?',
  answer: 'C - With proper load factor management, collisions are rare enough',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Collisions never happen in practice', 'correct' => false },
    { 'text' => 'Hash functions always prevent collisions', 'correct' => false },
    { 'text' => 'With proper load factor management, collisions are rare enough', 'correct' => true },
    { 'text' => 'Probing is always O(1)', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How is the hash function used to determine the position of a key-value pair in memory?',
  answer: 'A - Hash the key to get an array index',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hash the key to get an array index', 'correct' => true },
    { 'text' => 'Sort keys alphabetically', 'correct' => false },
    { 'text' => 'Use sequential placement', 'correct' => false },
    { 'text' => 'Random placement', 'correct' => false }
  ]
)

# Section C – Hash Index Operations (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What two operations in a hash index both benefit from constant-time access?',
  answer: 'C - Reads and writes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Reads and deletes', 'correct' => false },
    { 'text' => 'Writes and updates', 'correct' => false },
    { 'text' => 'Reads and writes', 'correct' => true },
    { 'text' => 'Scans and sorts', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why are hash indexes ideal for equality lookups (e.g., WHERE name = \'Jordan\')?',
  answer: 'A - They provide O(1) direct access to the exact key',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They provide O(1) direct access to the exact key', 'correct' => true },
    { 'text' => 'They maintain sorted order', 'correct' => false },
    { 'text' => 'They compress the data', 'correct' => false },
    { 'text' => 'They cache all values', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does each key-value pair in a hash index represent conceptually?',
  answer: 'B - An indexed field value and its row location',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'A table name and schema', 'correct' => false },
    { 'text' => 'An indexed field value and its row location', 'correct' => true },
    { 'text' => 'A column name and data type', 'correct' => false },
    { 'text' => 'A user and permission', 'correct' => false }
  ]
)

# Section D – Disk vs Memory (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What happens mechanically when a disk must jump to multiple random locations?',
  answer: 'C - The read/write arm moves repeatedly',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The platter spins faster', 'correct' => false },
    { 'text' => 'The cache clears', 'correct' => false },
    { 'text' => 'The read/write arm moves repeatedly', 'correct' => true },
    { 'text' => 'The disk rotates backwards', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is random I/O slow on mechanical hard drives?',
  answer: 'A - Mechanical arm movement (seek time) is slow',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Mechanical arm movement (seek time) is slow', 'correct' => true },
    { 'text' => 'Data must be decrypted', 'correct' => false },
    { 'text' => 'Bandwidth is limited', 'correct' => false },
    { 'text' => 'Cache misses occur', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What part of the disk physically limits performance in random access scenarios?',
  answer: 'B - The moving read/write arm',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The spinning platter', 'correct' => false },
    { 'text' => 'The moving read/write arm', 'correct' => true },
    { 'text' => 'The disk controller', 'correct' => false },
    { 'text' => 'The power supply', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why does storing the hash index in memory improve speed?',
  answer: 'C - Memory allows fast random access without mechanical movement',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Memory is larger than disk', 'correct' => false },
    { 'text' => 'Memory never fails', 'correct' => false },
    { 'text' => 'Memory allows fast random access without mechanical movement', 'correct' => true },
    { 'text' => 'Memory is cheaper than disk', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What limitation does keeping a hash index in RAM impose?',
  answer: 'B - The index size is limited by available RAM',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The index cannot be updated', 'correct' => false },
    { 'text' => 'The index size is limited by available RAM', 'correct' => true },
    { 'text' => 'The index is read-only', 'correct' => false },
    { 'text' => 'The index requires encryption', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is the total amount of RAM more limited than disk space?',
  answer: 'A - RAM is more expensive per gigabyte',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'RAM is more expensive per gigabyte', 'correct' => true },
    { 'text' => 'RAM requires more power', 'correct' => false },
    { 'text' => 'RAM is slower than disk', 'correct' => false },
    { 'text' => 'RAM cannot be expanded', 'correct' => false }
  ]
)

# Section E – Durability (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is durability such an important property for databases?',
  answer: 'C - Data must persist across crashes and restarts',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It makes queries faster', 'correct' => false },
    { 'text' => 'It reduces storage costs', 'correct' => false },
    { 'text' => 'Data must persist across crashes and restarts', 'correct' => true },
    { 'text' => 'It enables parallel processing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How does this affect the average latency of database writes when using a WAL?',
  answer: 'B - Writes become slower due to disk I/O overhead',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Writes become faster', 'correct' => false },
    { 'text' => 'Writes become slower due to disk I/O overhead', 'correct' => true },
    { 'text' => 'Latency is unchanged', 'correct' => false },
    { 'text' => 'Writes are eliminated', 'correct' => false }
  ]
)

# Section F – Range Queries (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Give an example of a range query using names.',
  answer: 'B - SELECT * FROM users WHERE name BETWEEN \'A\' AND \'C\'',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'SELECT * FROM users WHERE name = \'Alice\'', 'correct' => false },
    { 'text' => 'SELECT * FROM users WHERE name BETWEEN \'A\' AND \'C\'', 'correct' => true },
    { 'text' => 'SELECT * FROM users WHERE id = 1', 'correct' => false },
    { 'text' => 'SELECT * FROM users LIMIT 10', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the time complexity of performing a range query using a hash index?',
  answer: 'C - $O(n)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => false },
    { 'text' => '$O(\log n)$', 'correct' => false },
    { 'text' => '$O(n)$', 'correct' => true },
    { 'text' => '$O(n^2)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What alternative data structure can efficiently support range queries?',
  answer: 'C - Binary search tree / B-tree',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hash map', 'correct' => false },
    { 'text' => 'Array', 'correct' => false },
    { 'text' => 'Binary search tree / B-tree', 'correct' => true },
    { 'text' => 'Linked list', 'correct' => false }
  ]
)

# Section G – Trade-offs (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What type of queries are hash indexes optimized for?',
  answer: 'A - Equality lookups (single key)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Equality lookups (single key)', 'correct' => true },
    { 'text' => 'Range queries', 'correct' => false },
    { 'text' => 'Full table scans', 'correct' => false },
    { 'text' => 'Aggregations', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What type of queries are hash indexes NOT suitable for?',
  answer: 'B - Range queries',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Equality lookups', 'correct' => false },
    { 'text' => 'Range queries', 'correct' => true },
    { 'text' => 'Single-key lookups', 'correct' => false },
    { 'text' => 'Primary key searches', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'If you needed to store all student records and query by ID, which index type would you choose?',
  answer: 'A - Hash index (if dataset fits in RAM and only equality lookups needed)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hash index (if dataset fits in RAM and only equality lookups needed)', 'correct' => true },
    { 'text' => 'No index (full scans)', 'correct' => false },
    { 'text' => 'Text search index', 'correct' => false },
    { 'text' => 'Geospatial index', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'If you needed to list students with IDs between 1000 and 2000, which index type would perform better?',
  answer: 'B - B-tree index',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hash index', 'correct' => false },
    { 'text' => 'B-tree index', 'correct' => true },
    { 'text' => 'No index', 'correct' => false },
    { 'text' => 'Both perform equally', 'correct' => false }
  ]
)

puts "    ✓ Created 50 Hash Indexes multiple choice questions"

