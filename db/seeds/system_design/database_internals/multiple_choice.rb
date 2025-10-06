# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
database_internals = system_design.topic_modules.find_by!(name: 'Database Internals & Indexing')

puts '  - System Design multiple choice questions...'

# Section A – Persistence & Storage (8 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which type of memory loses all data when power is turned off?',
  answer: 'C - RAM',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'SSD', 'correct' => false },
    { 'text' => 'Hard drive', 'correct' => false },
    { 'text' => 'RAM', 'correct' => true },
    { 'text' => 'Flash storage', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What term describes data that remains available after a system restarts?',
  answer: 'B - Persistent data',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Transient data', 'correct' => false },
    { 'text' => 'Persistent data', 'correct' => true },
    { 'text' => 'Dynamic data', 'correct' => false },
    { 'text' => 'Cached data', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which of the following is non-volatile storage?',
  answer: 'C - SSD',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'RAM', 'correct' => false },
    { 'text' => 'CPU cache', 'correct' => false },
    { 'text' => 'SSD', 'correct' => true },
    { 'text' => 'Register memory', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why do databases use disks instead of RAM for permanent storage?',
  answer: 'B - RAM is volatile',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Disks are faster', 'correct' => false },
    { 'text' => 'RAM is volatile', 'correct' => true },
    { 'text' => 'RAM is cheaper', 'correct' => false },
    { 'text' => 'Disks are temporary', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the main drawback of storing a database entirely in RAM?',
  answer: 'B - Loss of data on shutdown',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'High durability', 'correct' => false },
    { 'text' => 'Loss of data on shutdown', 'correct' => true },
    { 'text' => 'Poor performance', 'correct' => false },
    { 'text' => 'Lack of indexing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which layer of the system interacts directly with stored data?',
  answer: 'B - Database software',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'CPU', 'correct' => false },
    { 'text' => 'Database software', 'correct' => true },
    { 'text' => 'RAM controller', 'correct' => false },
    { 'text' => 'Display driver', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: '"Durable" in database terminology most closely means:',
  answer: 'C - Remains after power loss',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Can handle large data', 'correct' => false },
    { 'text' => 'Resistant to corruption', 'correct' => false },
    { 'text' => 'Remains after power loss', 'correct' => true },
    { 'text' => 'Stored in cache', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which of the following best explains "persistent storage"?',
  answer: 'C - It retains information over time',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It holds temporary files', 'correct' => false },
    { 'text' => 'It keeps data during execution only', 'correct' => false },
    { 'text' => 'It retains information over time', 'correct' => true },
    { 'text' => 'It clears automatically after reboot', 'correct' => false }
  ]
)

# Section B – Disk Mechanics & Locality (7 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What component of a hard drive moves to locate data on the disk?',
  answer: 'B - Read/write arm',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'CPU', 'correct' => false },
    { 'text' => 'Read/write arm', 'correct' => true },
    { 'text' => 'Magnetic coil', 'correct' => false },
    { 'text' => 'Cache controller', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The time it takes for a hard drive arm to move to the right location is called:',
  answer: 'B - Seek time',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Rotation delay', 'correct' => false },
    { 'text' => 'Seek time', 'correct' => true },
    { 'text' => 'Access latency', 'correct' => false },
    { 'text' => 'Cache time', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why does storing related data contiguously improve performance?',
  answer: 'A - It reduces seek time',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It reduces seek time', 'correct' => true },
    { 'text' => 'It increases CPU usage', 'correct' => false },
    { 'text' => 'It compresses the data', 'correct' => false },
    { 'text' => 'It prevents fragmentation', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'When data is stored far apart on a spinning disk, performance slows due to:',
  answer: 'C - Increased arm movement',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Cache overflow', 'correct' => false },
    { 'text' => 'Fragmentation', 'correct' => false },
    { 'text' => 'Increased arm movement', 'correct' => true },
    { 'text' => 'Data compression', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A hard drive performs best when:',
  answer: 'B - Data is grouped together sequentially',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Data is evenly spaced', 'correct' => false },
    { 'text' => 'Data is grouped together sequentially', 'correct' => true },
    { 'text' => 'Files are randomised', 'correct' => false },
    { 'text' => 'There are many small files', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the physical structure of data on a hard disk most like?',
  answer: 'C - An array of bytes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'A 2D grid', 'correct' => false },
    { 'text' => 'A linked list', 'correct' => false },
    { 'text' => 'An array of bytes', 'correct' => true },
    { 'text' => 'A hash map', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'The performance cost of random I/O comes mainly from:',
  answer: 'B - Mechanical movement',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'CPU usage', 'correct' => false },
    { 'text' => 'Mechanical movement', 'correct' => true },
    { 'text' => 'Disk temperature', 'correct' => false },
    { 'text' => 'Memory bandwidth', 'correct' => false }
  ]
)

# Section C – Naïve Table Design (6 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is a "full table scan"?',
  answer: 'A - Reading every row one by one',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Reading every row one by one', 'correct' => true },
    { 'text' => 'Reading from an index', 'correct' => false },
    { 'text' => 'Skipping empty rows', 'correct' => false },
    { 'text' => 'Searching in memory', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the time complexity of finding a record in an unindexed table?',
  answer: 'C - $O(n)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => false },
    { 'text' => '$O(\log n)$', 'correct' => false },
    { 'text' => '$O(n)$', 'correct' => true },
    { 'text' => '$O(n \log n)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Updating a record in an unindexed table takes:',
  answer: 'B - Linear time',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Constant time', 'correct' => false },
    { 'text' => 'Linear time', 'correct' => true },
    { 'text' => 'Logarithmic time', 'correct' => false },
    { 'text' => 'Quadratic time', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why are both reads and writes slow in a naïve database table?',
  answer: 'B - Each must scan every record',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They require locking', 'correct' => false },
    { 'text' => 'Each must scan every record', 'correct' => true },
    { 'text' => 'Data is compressed', 'correct' => false },
    { 'text' => 'Indexes are corrupted', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'As a table grows, O(n) queries:',
  answer: 'A - Get slower',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Get slower', 'correct' => true },
    { 'text' => 'Stay constant', 'correct' => false },
    { 'text' => 'Get faster', 'correct' => false },
    { 'text' => 'Use less memory', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'If a table has 1 million rows, a full scan must:',
  answer: 'A - Check all 1 million rows',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Check all 1 million rows', 'correct' => true },
    { 'text' => 'Check only 1 row', 'correct' => false },
    { 'text' => 'Skip half of them', 'correct' => false },
    { 'text' => 'Use the CPU cache', 'correct' => false }
  ]
)

# Section D – Append-Only Storage (8 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'In an append-only database, how are updates stored?',
  answer: 'B - By appending a new version',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'By editing the existing record', 'correct' => false },
    { 'text' => 'By appending a new version', 'correct' => true },
    { 'text' => 'By deleting old data', 'correct' => false },
    { 'text' => 'By re-indexing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why are writes fast in append-only designs?',
  answer: 'A - They always write to the same place (end of file)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They always write to the same place (end of file)', 'correct' => true },
    { 'text' => 'They compress data first', 'correct' => false },
    { 'text' => 'They skip indexes', 'correct' => false },
    { 'text' => 'They use smaller blocks', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'In an append-only table, how does the system find the latest version of a record?',
  answer: 'B - By scanning from bottom up',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'By timestamp', 'correct' => false },
    { 'text' => 'By scanning from bottom up', 'correct' => true },
    { 'text' => 'By index ID', 'correct' => false },
    { 'text' => 'By record checksum', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the time complexity of writing in append-only design?',
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
  topic_module: database_internals,
  content: 'What is the time complexity of reading in append-only design?',
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
  topic_module: database_internals,
  content: 'What trade-off does append-only introduce?',
  answer: 'B - Faster writes, slower reads',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Faster reads, slower writes', 'correct' => false },
    { 'text' => 'Faster writes, slower reads', 'correct' => true },
    { 'text' => 'Smaller files, slower performance', 'correct' => false },
    { 'text' => 'Slower writes, smaller data', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'A major drawback of append-only tables is that they:',
  answer: 'B - Accumulate old versions',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Require disk compression', 'correct' => false },
    { 'text' => 'Accumulate old versions', 'correct' => true },
    { 'text' => 'Lose durability', 'correct' => false },
    { 'text' => 'Prevent backups', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Append-only storage is most appropriate when:',
  answer: 'A - Writes are frequent and updates are rare',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Writes are frequent and updates are rare', 'correct' => true },
    { 'text' => 'Reads dominate writes', 'correct' => false },
    { 'text' => 'Data must be deleted often', 'correct' => false },
    { 'text' => 'Storage space is limited', 'correct' => false }
  ]
)

# Section E – Read vs Write Trade-offs (4 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why do many large systems optimize for reads over writes?',
  answer: 'A - Reads are usually more common',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Reads are usually more common', 'correct' => true },
    { 'text' => 'Writes are safer', 'correct' => false },
    { 'text' => 'Reads take less memory', 'correct' => false },
    { 'text' => 'Writes are easier to cache', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which system type is most read-heavy?',
  answer: 'C - Social media feed',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Logging service', 'correct' => false },
    { 'text' => 'Analytics pipeline', 'correct' => false },
    { 'text' => 'Social media feed', 'correct' => true },
    { 'text' => 'ETL batch job', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why is O(n) read time unacceptable in large-scale systems?',
  answer: 'A - It scales linearly with data',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It scales linearly with data', 'correct' => true },
    { 'text' => 'It consumes too much disk space', 'correct' => false },
    { 'text' => 'It violates normalization', 'correct' => false },
    { 'text' => 'It increases redundancy', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which statement best describes the read–write balance in most web applications?',
  answer: 'B - Mostly reads',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Mostly writes', 'correct' => false },
    { 'text' => 'Mostly reads', 'correct' => true },
    { 'text' => 'Equal reads and writes', 'correct' => false },
    { 'text' => 'Mostly deletes', 'correct' => false }
  ]
)

# Section F – Index Basics (8 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the main function of a database index?',
  answer: 'B - To speed up lookups',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'To compress data', 'correct' => false },
    { 'text' => 'To speed up lookups', 'correct' => true },
    { 'text' => 'To ensure consistency', 'correct' => false },
    { 'text' => 'To manage connections', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which operation becomes slower when indexes are added?',
  answer: 'B - Writing',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Reading', 'correct' => false },
    { 'text' => 'Writing', 'correct' => true },
    { 'text' => 'Deleting indexes', 'correct' => false },
    { 'text' => 'Query parsing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why does writing slow down when indexes exist?',
  answer: 'A - Indexes must be updated too',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Indexes must be updated too', 'correct' => true },
    { 'text' => 'Data compression occurs', 'correct' => false },
    { 'text' => 'Memory caching increases', 'correct' => false },
    { 'text' => 'Disk bandwidth decreases', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is a composite index?',
  answer: 'A - An index on multiple columns',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'An index on multiple columns', 'correct' => true },
    { 'text' => 'A compressed index', 'correct' => false },
    { 'text' => 'An index stored in RAM', 'correct' => false },
    { 'text' => 'A temporary index', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is the typical time complexity for indexed lookups using a B-tree?',
  answer: 'B - $O(\log n)$',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => '$O(1)$', 'correct' => false },
    { 'text' => '$O(\log n)$', 'correct' => true },
    { 'text' => '$O(n)$', 'correct' => false },
    { 'text' => '$O(n^2)$', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What trade-off do indexes create?',
  answer: 'A - Faster reads, slower writes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Faster reads, slower writes', 'correct' => true },
    { 'text' => 'Faster writes, slower reads', 'correct' => false },
    { 'text' => 'Slower reads and writes', 'correct' => false },
    { 'text' => 'No change in performance', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which column would most benefit from an index in a user database?',
  answer: 'A - User ID',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'User ID', 'correct' => true },
    { 'text' => 'Biography text', 'correct' => false },
    { 'text' => 'Profile picture', 'correct' => false },
    { 'text' => 'Notes field', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which of the following best describes the purpose of indexing?',
  answer: 'A - To organize data for faster retrieval',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'To organize data for faster retrieval', 'correct' => true },
    { 'text' => 'To make data immutable', 'correct' => false },
    { 'text' => 'To enforce referential integrity', 'correct' => false },
    { 'text' => 'To compress files', 'correct' => false }
  ]
)

# Section G – Range Queries (6 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What does a range query do?',
  answer: 'B - Fetches records between two values',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Fetches records matching a pattern', 'correct' => false },
    { 'text' => 'Fetches records between two values', 'correct' => true },
    { 'text' => 'Fetches records by hash key', 'correct' => false },
    { 'text' => 'Deletes old records', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which query is an example of a range query?',
  answer: "B - name BETWEEN 'A' AND 'C'",
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => "name = 'John'", 'correct' => false },
    { 'text' => "name BETWEEN 'A' AND 'C'", 'correct' => true },
    { 'text' => 'shoe_size = 12', 'correct' => false },
    { 'text' => 'id = 5', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Range queries are best optimized using:',
  answer: 'C - Ordered indexes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hash indexes', 'correct' => false },
    { 'text' => 'Random scans', 'correct' => false },
    { 'text' => 'Ordered indexes', 'correct' => true },
    { 'text' => 'Append-only writes', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why are hash indexes poor for range queries?',
  answer: 'A - Hashes destroy order',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Hashes destroy order', 'correct' => true },
    { 'text' => 'They use too much memory', 'correct' => false },
    { 'text' => 'They cache values incorrectly', 'correct' => false },
    { 'text' => 'They require sorting', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What is one example of a real-world range query?',
  answer: 'A - Posts from the last 24 hours',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Posts from the last 24 hours', 'correct' => true },
    { 'text' => 'User by ID', 'correct' => false },
    { 'text' => 'Login by email', 'correct' => false },
    { 'text' => 'File by checksum', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which type of index structure stores sorted keys?',
  answer: 'A - B-tree',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'B-tree', 'correct' => true },
    { 'text' => 'Hash map', 'correct' => false },
    { 'text' => 'Bloom filter', 'correct' => false },
    { 'text' => 'Trie', 'correct' => false }
  ]
)

# Section H – Performance & Scaling (5 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What happens to performance if the dataset doubles in size for an O(n) operation?',
  answer: 'B - It doubles',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It stays the same', 'correct' => false },
    { 'text' => 'It doubles', 'correct' => true },
    { 'text' => 'It halves', 'correct' => false },
    { 'text' => 'It becomes constant', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What Big-O complexity is considered scalable for large reads?',
  answer: 'A - O(1) or O(log n)',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'O(1) or O(log n)', 'correct' => true },
    { 'text' => '$O(n)$', 'correct' => false },
    { 'text' => '$O(n^2)$', 'correct' => false },
    { 'text' => 'O(2ⁿ)', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which component dominates latency on hard drives?',
  answer: 'A - Disk seeks',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Disk seeks', 'correct' => true },
    { 'text' => 'CPU cache', 'correct' => false },
    { 'text' => 'Network delay', 'correct' => false },
    { 'text' => 'File system metadata', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why do databases model performance mathematically?',
  answer: 'A - To predict how performance changes with scale',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'To predict how performance changes with scale', 'correct' => true },
    { 'text' => 'To replace hardware tuning', 'correct' => false },
    { 'text' => 'To compress queries', 'correct' => false },
    { 'text' => 'To simplify code', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which approach helps maintain performance when data grows?',
  answer: 'A - Indexing',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Indexing', 'correct' => true },
    { 'text' => 'Ignoring writes', 'correct' => false },
    { 'text' => 'Duplicating data', 'correct' => false },
    { 'text' => 'Using CSV files', 'correct' => false }
  ]
)

# Section I – Conceptual & Design Trade-offs (8 Questions)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which of the following is the core design trade-off in databases?',
  answer: 'B - Read speed vs write speed',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Security vs availability', 'correct' => false },
    { 'text' => 'Read speed vs write speed', 'correct' => true },
    { 'text' => 'Cost vs usability', 'correct' => false },
    { 'text' => 'Redundancy vs persistence', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: "Why can't databases optimize both reads and writes perfectly?",
  answer: 'A - Each design favors different access patterns',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Each design favors different access patterns', 'correct' => true },
    { 'text' => 'Hardware prevents it', 'correct' => false },
    { 'text' => 'Users cause too many conflicts', 'correct' => false },
    { 'text' => 'Memory limits disallow it', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'In what type of workload are fast writes more critical than reads?',
  answer: 'A - Logging systems',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Logging systems', 'correct' => true },
    { 'text' => 'Social media feeds', 'correct' => false },
    { 'text' => 'Analytics dashboards', 'correct' => false },
    { 'text' => 'Content delivery networks', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which of the following is a result of adding too many indexes?',
  answer: 'B - Slower updates',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Faster inserts', 'correct' => false },
    { 'text' => 'Slower updates', 'correct' => true },
    { 'text' => 'Smaller file size', 'correct' => false },
    { 'text' => 'Fewer reads', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which design choice best improves user experience on read-heavy apps?',
  answer: 'A - Add indexes',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Add indexes', 'correct' => true },
    { 'text' => 'Remove indexes', 'correct' => false },
    { 'text' => 'Use full scans', 'correct' => false },
    { 'text' => 'Delete logs frequently', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: "The key reason O(n) operations don't scale is that:",
  answer: 'A - Work grows linearly with data size',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Work grows linearly with data size', 'correct' => true },
    { 'text' => 'Memory usage decreases', 'correct' => false },
    { 'text' => 'Disk speed improves linearly', 'correct' => false },
    { 'text' => 'CPU time becomes negligible', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: "What's the main reason to keep frequently accessed data in cache?",
  answer: 'A - It avoids disk seeks',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It avoids disk seeks', 'correct' => true },
    { 'text' => 'It increases durability', 'correct' => false },
    { 'text' => 'It reduces redundancy', 'correct' => false },
    { 'text' => 'It prevents indexing', 'correct' => false }
  ]
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Which data structure is most commonly used to implement ordered indexes in databases?',
  answer: 'B - B-tree',
  points: 1,
  answer_size: 'short',
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Linked list', 'correct' => false },
    { 'text' => 'B-tree', 'correct' => true },
    { 'text' => 'Hash map', 'correct' => false },
    { 'text' => 'Graph', 'correct' => false }
  ]
)

puts "  ✓ Created 60 System Design multiple choice questions"

