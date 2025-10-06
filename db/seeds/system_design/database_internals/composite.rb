# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
database_internals = system_design.topic_modules.find_by!(name: 'Database Internals & Indexing')

puts '  - System Design composite questions...'

# Block A – Naïve Table Design (Questions 12a-e)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about a simple database table with two columns: name and shoe_size.',
  answer: 'a) Example rows; b) Full table scan; c) O(n); d) O(n); e) Both require linear scanning',
  points: 8,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Give three realistic example rows.', 'answer_size' => 'short', 'points' => 1 },
      { 'type' => 'written', 'content' => "b) How would the database find the row where name = 'Jordan' if no special optimization is used?", 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What is the time complexity of searching for a single record by name in this unoptimized table?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What is the time complexity of updating a single record by name in the same table?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why do both reads and writes have O(n) time complexity in this simple design?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block B – Append-Only Optimization (Questions 13a-f)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about append-only database design.',
  answer: 'a) Append-only design; b) Records changes by appending; c) Scans newest entries; d) Reads remain O(n); e) Writes become O(1); f) Fast writes but slower reads',
  points: 12,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What strategy can be used to make writes faster in a simple table?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How does an append-only design avoid editing existing rows on disk?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) In an append-only table, how does the database determine which version of a record is the most recent?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How does the append-only approach affect read performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) How does the append-only approach affect write performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'f) What is the main trade-off introduced by the append-only strategy?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block C – Read vs Write Priorities (Questions 14a-c)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about read and write performance priorities in database systems.',
  answer: 'a) Most workloads have more reads than writes; b) Scanning millions of records is too slow; c) Example: Facebook news feed',
  points: 6,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Why might large-scale systems prioritize read performance over write performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why is O(n) read time unacceptable for modern web applications?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Give a practical example where scanning all rows for every query would be impractical.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block D – Database Indexes (Questions 15a-g)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about database indexes.',
  answer: 'a) Index definition; b) Improves reads; c) Slows writes; d) Optimized for single field; e) name and shoe_size; f) Multi-column index; g) Faster reads, slower writes',
  points: 14,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is a database index and why is it used?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How does creating an index affect the speed of read operations?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) How does creating an index affect the speed of write operations?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => "d) Why is an index typically built on one column (field) of a table?", 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What are two different columns in a name–shoe_size table that could each have their own index?', 'answer_size' => 'short', 'points' => 1 },
      { 'type' => 'written', 'content' => 'f) What is a composite index in databases?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'g) What general trade-off do indexes create?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block E – Range Queries (Questions 16a-e)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about range queries in databases.',
  answer: 'a) Query retrieving records between boundaries; b) BETWEEN A AND B; c) Posts in time range; d) Indexes maintain sorted order; e) Must examine every record',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is a range query in databases?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Give an example of a range query using names as the key.', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Give an example of a range query on time data in a social-media database.', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why are range queries a common case where indexes are beneficial?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why does a database without indexes perform poorly on range queries?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block F – Conceptual Summary (Questions 17a-e)
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following conceptual questions about database performance and design.',
  answer: 'a) Contiguous data enables fast sequential reads; b) Improving one often worsens the other; c) Persistence needs non-volatile media with speed limits; d) O(n) does not scale; e) Hash tables or B-trees',
  points: 12,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) How does the physical layout of data on disk influence database performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is the trade-off between optimizing for reads versus writes?', 'answer_size' => 'medium', 'points' => 3 },
      { 'type' => 'written', 'content' => 'c) How are persistence, storage medium, and performance related?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why was indexing introduced as a response to linear search?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What types of data structures are commonly used to implement indexes, and why?', 'answer_size' => 'medium', 'points' => 3 }
    ]
  }
)

# Block G – Persistence & Storage Media
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about persistence and storage media in databases.',
  answer: 'a) Persistence means data survives restarts; b) RAM is volatile; c) Hard drives are non-volatile; d) Databases store persistent data on disk; e) Software mediates access',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What does it mean for data to be persistent?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why is RAM unsuitable for persistent storage?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why are hard drives typically used for persistence?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) In a database system, where is persistent data physically stored?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Which software component interacts with this stored data?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block H – Disk Mechanics & Locality
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about hard drive mechanics and data locality.',
  answer: 'a) A spinning platter and moving arm; b) Arm movement is slow; c) Close data = fewer seeks; d) Random placement slows performance; e) Sequential layout improves throughput',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What are the main physical parts of a traditional hard drive?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why does arm movement limit read speed?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why is data locality important for performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What happens if related records are stored far apart on disk?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) How does sequential storage layout improve performance?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block I – Linear Search and Complexity
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about linear search in unindexed databases.',
  answer: 'a) It checks each record sequentially; b) O(n) complexity; c) Scales poorly with data size; d) Causes long read times; e) Inefficient for large systems',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is a linear search in the context of databases?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is the time complexity of a linear search?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why does this approach scale poorly?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What effect does this have on read performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why is this design unsuitable for large applications?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block J – Comparing Read and Write Trade-offs
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about trade-offs between read and write optimization.',
  answer: 'a) Reads can be optimized by indexing; b) Writes can be optimized by append-only; c) Each optimization hurts the other; d) Choose based on workload; e) Read-heavy systems prioritize read speed',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What design choice improves read speed the most?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What design choice improves write speed the most?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => "c) Why can't both be fully optimized at once?", 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How should a system designer decide which to optimize?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What type of workload typically prioritizes read speed?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block K – Example Query Scenarios
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about real-world database queries.',
  answer: 'a) Equality lookup; b) Range query; c) Full scan is too slow; d) Index accelerates lookups; e) Example: retrieving social media posts in time range',
  points: 10,
  answer_size: 'short',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is an example of a query that benefits from an index?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is a range query?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why would scanning every row be too slow for such queries?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How does an index improve this case?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Give a real-world example of a range query in a web app.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block L – Cost of Indexing
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about the costs and trade-offs of indexing.',
  answer: 'a) Index speeds reads; b) Slows writes; c) Consumes space; d) Needs maintenance; e) Worth it for read-heavy tables',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What operation does indexing make faster?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What operation does indexing make slower?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What extra resource does an index consume?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why must indexes be maintained after every write?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) When is indexing most beneficial?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block M – Physical vs Logical Design
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about the relationship between physical and logical database design.',
  answer: 'a) Logical defines schema; b) Physical defines storage; c) Both affect performance; d) Locality matters; e) Good physical design supports fast logical queries',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What is logical database design concerned with?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) What is physical database design concerned with?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) How do these two designs interact?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) Why does physical data locality affect logical query speed?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What is one benefit of aligning physical and logical layouts?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block N – Scaling with Data Size
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about database scaling as data size increases.',
  answer: 'a) Workload grows linearly with data; b) O(n) is unacceptable at scale; c) Indexing reduces cost; d) Partitioning helps; e) Trade-offs remain',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) How does data growth affect O(n) operations?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Why is O(n) complexity unacceptable for large systems?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What common optimization reduces this cost?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What other technique (besides indexing) helps large data sets?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => "e) Why can't scaling eliminate all trade-offs?", 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block O – Append-Only Real-World Applications
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about where append-only designs are useful.',
  answer: 'a) Logging systems; b) Event sourcing; c) Data immutability; d) Easier recovery; e) Harder reads',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What kind of systems benefit most from append-only writes?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How is append-only used in event sourcing?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why is immutability valuable for reliability?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How does append-only simplify data recovery?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) What is a downside for query performance?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block P – Range Queries and Ordered Structures
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about ordered data structures and range queries.',
  answer: 'a) Ordered data allows range lookups; b) B-trees store keys sorted; c) Hashes cannot handle ranges; d) Sorted indexes make range scans fast; e) Example: posts by date',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) Why do ordered data structures help with range queries?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How does a B-tree store data internally?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) Why are hash indexes unsuitable for range queries?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How does maintaining order improve scan performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Give an example of an ordered query in a social app.', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block Q – Performance Modeling
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about modeling database performance.',
  answer: 'a) Reads, writes, and seeks; b) Disk seeks dominate latency; c) Indexing reduces seeks; d) Cache reduces reads; e) Model predicts trade-offs',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What are the main operations that affect performance in a database?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) Which of these operations usually dominates latency on hard drives?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) How does indexing reduce total seek cost?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What role does caching play in performance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why is it useful to model performance mathematically?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block R – Real-World System Trade-offs
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions about real-world trade-offs in database design.',
  answer: 'a) Fast reads vs writes; b) User experience impact; c) Business trade-offs; d) Hardware limits; e) No perfect balance',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) What opposing goals must database designers balance?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How do these trade-offs affect user experience?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) How can business requirements influence these choices?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) How do hardware constraints shape these trade-offs?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) Why can no single design be optimal for all cases?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

# Block S – Index Structure Comparison
Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Answer the following questions comparing different index structures.',
  answer: 'a) Hash indexes use key hashing; b) B-trees use sorted order; c) Hash = O(1) lookups; d) B-tree = O(log n) ordered lookups; e) Use case depends on query pattern',
  points: 10,
  answer_size: 'medium',
  question_type: 'composite',
  options: {
    'parts' => [
      { 'type' => 'written', 'content' => 'a) How does a hash index locate a record?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'b) How does a B-tree index locate a record?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'c) What is the lookup complexity of a hash index?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'd) What is the lookup complexity of a B-tree index?', 'answer_size' => 'short', 'points' => 2 },
      { 'type' => 'written', 'content' => 'e) How should you choose between them?', 'answer_size' => 'short', 'points' => 2 }
    ]
  }
)

puts "  ✓ Created 21 System Design composite questions"

