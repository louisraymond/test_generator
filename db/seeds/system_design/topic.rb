# frozen_string_literal: true

puts 'Creating System Design topic...'

system_design = Topic.create!(
  name: 'System Design'
)

puts '  Creating modules...'

# Create Database Internals module
database_internals = TopicModule.create!(
  topic: system_design,
  name: 'Database Internals & Indexing',
  description: 'Core concepts of how databases store data, including persistence, disk mechanics, and basic indexing principles',
  position: 1
)

# Create Hash Indexes module
hash_indexes = TopicModule.create!(
  topic: system_design,
  name: 'Hash Indexes',
  description: 'In-depth study of hash-based indexing, including hash maps, collisions, write-ahead logs, and trade-offs',
  position: 2
)

puts "  ✓ Created #{system_design.topic_modules.count} modules"

puts '  Creating learning objectives for Database Internals...'

# Database Internals Module - Persistence & Storage Media
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Persistence & Storage Media', description: 'Define what data persistence means in computing', position: 1)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Persistence & Storage Media', description: 'Identify why RAM cannot store data persistently', position: 2)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Persistence & Storage Media', description: 'Explain why hard drives, not RAM, are used for persistent database storage', position: 3)

# Disk Mechanics & Data Locality
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Disk Mechanics & Data Locality', description: 'Recall the physical components of a traditional hard drive (platter, arm, head)', position: 4)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Disk Mechanics & Data Locality', description: 'Describe how the physical layout of data on disk affects read/write performance', position: 5)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Disk Mechanics & Data Locality', description: 'Explain why sequential (contiguous) storage of related data improves access speed', position: 6)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Disk Mechanics & Data Locality', description: 'Distinguish between the performance impacts of sequential and random I/O access on spinning disks', position: 7)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Disk Mechanics & Data Locality', description: 'Predict how storing related records closer together would affect the number of disk seeks required', position: 8)

# Table Design & Complexity
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Table Design & Complexity', description: 'Illustrate how a simple database table (e.g. name and shoe_size) is stored and accessed on disk', position: 9)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Table Design & Complexity', description: 'Recognize that naïve database operations on unindexed tables have O(n) complexity for reads and writes', position: 10)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Table Design & Complexity', description: 'Discuss why read and write operations in an unindexed table both have O(n) time complexity', position: 11)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Table Design & Complexity', description: 'Given an example database table, determine the time complexity of basic read and write operations', position: 12)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Table Design & Complexity', description: 'Critically discuss the limitations of linear (O(n)) scans in large-scale database systems', position: 13)

# Append-Only Storage
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Append-Only Storage', description: 'Explain how an append-only (log-structured) storage design changes read and write performance characteristics', position: 14)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Append-Only Storage', description: 'Demonstrate how appending new data rather than updating in place changes the steps required for reading and writing', position: 15)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Append-Only Storage', description: 'Compare the performance implications of in-place updates versus append-only writes', position: 16)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Append-Only Storage', description: 'Evaluate when append-only storage is advantageous and when it becomes inefficient', position: 17)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Append-Only Storage', description: 'Outline how to extend an append-only storage model to support efficient lookups (e.g., through background compaction or indexing)', position: 18)

# Read vs Write Trade-offs
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Read vs Write Trade-offs', description: 'Describe the trade-off between optimizing read speed and write speed', position: 19)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Read vs Write Trade-offs', description: 'Judge whether a system should favor read performance or write performance given a specific workload (e.g., Facebook feed vs. logging system)', position: 20)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Read vs Write Trade-offs', description: 'Formulate a strategy to balance persistence, read speed, and write efficiency for a hypothetical application', position: 21)

# Database Indexes
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'State what an index is in the context of databases', position: 22)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Summarize what a database index does and how it affects performance for different types of queries', position: 23)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'List examples of typical database queries that benefit from indexing (e.g., equality lookups, range queries)', position: 24)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Apply the concept of indexing to propose a performance improvement for a given table structure', position: 25)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Identify suitable fields to index in a sample dataset (e.g., user names, timestamps)', position: 26)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Differentiate between single-column indexes and composite (multi-column) indexes', position: 27)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Analyze how adding indexes introduces trade-offs between read latency, write latency, and storage overhead', position: 28)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Assess whether adding an index on a particular field is worthwhile, based on query frequency and write volume', position: 29)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Justify why databases use indexing structures such as B-trees or hash tables instead of scanning entire tables', position: 30)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Database Indexes', description: 'Construct an argument for which fields to index in a sample web-app database', position: 31)

# Range Queries
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Range Queries', description: 'Interpret what a range query is and why it is common in real applications', position: 32)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Range Queries', description: 'Analyze why range queries perform poorly without indexes but efficiently with ordered data structures (like B-trees)', position: 33)

# Performance & Scaling
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Performance & Scaling', description: 'Develop a simple performance model that predicts the effect of indexing on read/write times', position: 34)
LearningObjective.create!(topic: system_design, topic_module: database_internals, category: 'Performance & Scaling', description: 'Design a small example dataset and propose how to physically store it on disk for optimal read speed', position: 35)

puts "  ✓ Created #{database_internals.learning_objectives.count} learning objectives for Database Internals"

puts '  Creating learning objectives for Hash Indexes...'

# Hash Indexes Module - Hash Functions & Hash Maps
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Define what a hash function is and its key deterministic property', position: 1)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Explain how hash maps achieve O(1) read and write operations', position: 2)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Describe what a hash collision is and why it occurs', position: 3)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Compare collision resolution methods: chaining versus probing', position: 4)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Explain the concept of load factor and its impact on hash map performance', position: 5)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Functions & Hash Maps', description: 'Differentiate between hash maps and hash sets', position: 6)

# Hash Index Implementation
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Index Implementation', description: 'Explain how a hash index uses a hash map to speed up database lookups', position: 7)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Index Implementation', description: 'Describe what key-value pairs in a hash index represent', position: 8)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Index Implementation', description: 'Identify why hash indexes are ideal for equality lookups', position: 9)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Hash Index Implementation', description: 'Demonstrate how hash indexes achieve O(1) read and write time complexity', position: 10)

# Memory vs Disk Storage
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Memory vs Disk Storage', description: 'Explain why hash indexes are typically kept in RAM rather than on disk', position: 11)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Memory vs Disk Storage', description: 'Describe why scattered data distribution causes poor performance on mechanical hard drives', position: 12)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Memory vs Disk Storage', description: 'Identify the constraint that hash indexes must fit in available RAM', position: 13)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Memory vs Disk Storage', description: 'Analyze the cost implications of RAM versus disk storage for indexes', position: 14)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Memory vs Disk Storage', description: 'Evaluate how SSDs might change the performance profile of hash indexes', position: 15)

# Durability & Write-Ahead Logs
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Identify the problem of volatility when keeping hash indexes in RAM', position: 16)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Explain what a write-ahead log (WAL) is and why it is needed', position: 17)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Describe how a WAL provides durability for in-memory hash indexes', position: 18)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Explain why sequential writes to a WAL are faster than random writes', position: 19)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Outline the steps to rebuild a hash index from a WAL after a crash', position: 20)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Durability & Write-Ahead Logs', description: 'Analyze the performance trade-off introduced by using a WAL', position: 21)

# Range Queries & Limitations
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Range Queries & Limitations', description: 'Define what a range query is in the context of databases', position: 22)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Range Queries & Limitations', description: 'Explain why hash indexes cannot efficiently handle range queries', position: 23)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Range Queries & Limitations', description: 'Describe why hash functions destroy the ordering of keys', position: 24)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Range Queries & Limitations', description: 'Calculate the time complexity of performing a range query using a hash index', position: 25)

# Comparison with Other Index Types
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Comparison with Other Index Types', description: 'Compare the time complexity of hash indexes versus B-tree indexes', position: 26)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Comparison with Other Index Types', description: 'Contrast the capabilities of hash indexes and tree-based indexes for range queries', position: 27)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Comparison with Other Index Types', description: 'Explain the fundamental difference in how hash indexes and tree indexes organize keys', position: 28)

# Trade-offs & Use Cases
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Trade-offs & Use Cases', description: 'Summarize the performance characteristics of hash indexes', position: 29)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Trade-offs & Use Cases', description: 'Identify suitable use cases for hash indexes (e.g., session storage, caching)', position: 30)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Trade-offs & Use Cases', description: 'Evaluate when hash indexes are advantageous versus when they become impractical', position: 31)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Trade-offs & Use Cases', description: 'Assess the trade-offs between read speed, write speed, durability, and capacity', position: 32)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'Trade-offs & Use Cases', description: 'Judge which index type to use based on workload characteristics', position: 33)

# System Design Principles
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'System Design Principles', description: 'Analyze how the RAM + WAL combination achieves both speed and durability', position: 34)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'System Design Principles', description: 'Design a hybrid index structure combining hash maps and trees', position: 35)
LearningObjective.create!(topic: system_design, topic_module: hash_indexes, category: 'System Design Principles', description: 'Evaluate the "no free lunch" principle in optimization through hash index design', position: 36)

puts "  ✓ Created #{hash_indexes.learning_objectives.count} learning objectives for Hash Indexes"

puts "  ✓ Created topic: #{system_design.name}"

