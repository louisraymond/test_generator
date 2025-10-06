# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
hash_indexes = system_design.topic_modules.find_by!(name: 'Hash Indexes')

puts '    - Hash Indexes written questions...'

# Hash Function & Hash Map Fundamentals

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is a hash function and what property makes it useful for indexing?',
  answer: 'A hash function is a black box that takes an input (like a key) and always returns the same numeric output for that input. The deterministic property (same input always produces same output) makes it useful for indexing because we can reliably map keys to consistent locations.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Explain how a hash map achieves O(1) read and write operations.',
  answer: 'A hash map uses a hash function to convert a key into an array index in constant time. It can then directly jump to that index in the array to read or write the value, which is also constant time. This direct addressing allows O(1) operations.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is a hash collision and describe two methods for handling it.',
  answer: 'A hash collision occurs when two different keys hash to the same index. Two methods to handle it: 1) Chaining - store a linked list at each index, where colliding elements are added to the list. 2) Probing - look for the next available spot in the array and place the element there.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

# Hash Index Implementation

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How does a hash index use a hash map to speed up database lookups?',
  answer: 'A hash index stores keys (like names or IDs) in a hash map where the key maps to the location on disk where the actual row is stored (or the row itself). This allows O(1) lookup time to find where a row is located instead of scanning all rows.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why are hash indexes typically kept in RAM rather than on disk?',
  answer: 'Hash maps distribute elements evenly across an array, which means elements are scattered all over memory. On disk, this would require many random seeks with the disk arm jumping around, causing poor performance. RAM allows random access without mechanical movement, making it much faster for hash index operations.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

# Durability & Write-Ahead Log

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What problem does keeping a hash index in RAM create, and how is it solved?',
  answer: 'RAM is volatile, so if the computer shuts down, all data in the hash index is lost. This is solved using a write-ahead log (WAL) stored on disk that records all writes and updates. If the system crashes, the hash index can be rebuilt by replaying all operations in the WAL.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Describe how a write-ahead log provides durability for a hash index.',
  answer: 'A write-ahead log sequentially records every database write/update operation on disk before it is applied. Since writes are sequential, they are relatively fast on disk. If the system crashes, the log can be replayed from start to finish to reconstruct the hash index, ensuring no data is lost.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why are sequential writes to a write-ahead log faster than random writes on a hard drive?',
  answer: 'Sequential writes place data in adjacent locations on disk, requiring minimal disk arm movement. The arm only needs to move once and then can write continuously as the platter spins. Random writes require the arm to jump around to different locations, causing many slow seek operations.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Limitations & Trade-offs

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why can\'t hash indexes efficiently handle range queries like "find all names between A and B"?',
  answer: 'Hash functions distribute keys randomly across the array, destroying any ordering. To find all names between A and B, you would need to either: 1) check every possible string between A and B (infinite), or 2) scan all indexes in the hash map (O(n)). Neither is efficient, making range queries impractical with hash indexes.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What are the main trade-offs of using a hash index compared to scanning all database rows?',
  answer: 'Benefits: O(1) reads and writes instead of O(n), much faster lookups. Trade-offs: Must keep all keys in RAM (expensive and limited capacity), cannot do range queries, requires write-ahead log for durability (adds write overhead), and only works well for small enough datasets that fit in memory.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'When would a hash index be a good choice for a database?',
  answer: 'Hash indexes are ideal when: 1) the dataset is small enough to fit in RAM, 2) queries look up individual rows by key rather than ranges, 3) O(1) read/write performance is critical, and 4) you don\'t need range queries. Example: caching layer, session storage, or small lookup tables.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Compare hash indexes with binary search trees for database indexing. What are the key differences in performance?',
  answer: 'Hash indexes provide O(1) reads/writes but cannot handle range queries. Binary search trees (like B-trees) provide O(log n) reads/writes but can efficiently handle range queries due to maintained ordering. Hash indexes are faster for single-key lookups but less versatile.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

# Section A – Review & Context

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What problem do indexes aim to solve in databases?',
  answer: 'Indexes solve the problem of O(n) reads, where the database must scan through all rows to find the records it needs. Indexes provide faster data access by avoiding full table scans.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why are O(n) reads undesirable in large datasets?',
  answer: 'O(n) reads scale linearly with data size, meaning query time grows proportionally with the number of rows. For large datasets with millions of records, this makes response times unacceptably slow.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'In the absence of indexes, what operation must the database perform to find a record?',
  answer: 'The database must perform a full table scan, checking every single row one by one until it finds the matching record(s).',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Section B – Hash Map Fundamentals (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is a hash function often described as a "black box"?',
  answer: 'It is called a black box because we do not need to know the internal implementation details. We only know that it consistently maps inputs to outputs in a deterministic way.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why can two different inputs produce the same output in a hash function?',
  answer: 'Because the input space is typically much larger than the output space. For example, there are infinite possible strings but a hash function might only return values from 0-10, so collisions are inevitable.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why does probing potentially break the ideal constant-time property of hash maps?',
  answer: 'With probing, when a collision occurs, the hash map must search linearly for the next available spot. In worst cases with many collisions, this can degrade to O(n) lookup time. However, with proper load factor management, average case remains O(1).',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the load factor in a hash map, and what does it measure?',
  answer: 'The load factor is the ratio of filled slots to total slots in the hash map array. It measures how full the hash map is. A higher load factor means more collisions, while maintaining a reasonable load factor (typically < 0.75) helps preserve O(1) performance.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the difference between a hash map and a hash set?',
  answer: 'A hash map stores key-value pairs, where each key maps to an associated value. A hash set only stores keys (or values) without associated data, used primarily for membership testing.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Section C – Hash Index Basics (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does "address on disk" mean in the context of a hash index?',
  answer: 'An address on disk is a physical location or byte offset on the storage medium where a row\'s data is stored. It allows direct access to the row without scanning, similar to an array index.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What happens when two different keys hash to the same disk address in a hash index?',
  answer: 'This is a hash collision. The hash index handles it the same way as a regular hash map - either through chaining (storing a linked list of entries) or probing (finding the next available location).',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What makes the hash index design simple but powerful?',
  answer: 'Its simplicity comes from directly applying hash map data structures to database indexing. Its power comes from O(1) lookups and inserts, dramatically faster than O(n) full table scans, making single-key queries extremely efficient.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Section D – Hash Indexes on Disk vs Memory (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What physical property of hard drives causes hash maps to be inefficient on disk?',
  answer: 'Hard drives have a mechanical read/write arm that must physically move to different locations on the spinning platter. This mechanical movement (seek time) is very slow compared to electronic operations.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How are elements distributed in a hash map\'s array, and why does this cause problems for disk-based storage?',
  answer: 'Hash functions intentionally distribute elements evenly across the array to avoid clustering. On disk, this means data is scattered all over the platter, requiring many slow random seeks with the disk arm jumping around constantly.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is it acceptable for hash indexes to require fitting in RAM for small datasets but problematic for large ones?',
  answer: 'Small datasets can easily fit in the available RAM at reasonable cost. Large datasets may require terabytes of RAM, which is prohibitively expensive and may exceed physical limitations of the server hardware.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Section E – Volatility & Durability (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What happens to the in-memory hash index when the computer shuts down?',
  answer: 'All data in RAM is lost because RAM is volatile memory. The entire hash index disappears, and without a durability mechanism like a write-ahead log, all index data would be permanently lost.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is this lack of durability unacceptable for databases?',
  answer: 'Databases must guarantee data persistence across system restarts, crashes, and power failures. Losing data on shutdown would make the database unreliable and unsuitable for any production use where data integrity is critical.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What type of operations does the Write-Ahead Log (WAL) record?',
  answer: 'The WAL records all write and update operations made to the database, such as inserts, updates, deletes, and modifications to indexed values. Each operation is logged sequentially before being applied.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is the WAL written sequentially rather than randomly?',
  answer: 'Sequential writes place data in adjacent locations on disk, requiring only one initial seek followed by continuous writing as the platter spins. This is much faster than random writes which require many seeks.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What steps are followed to "replay" the WAL to restore the index after a crash?',
  answer: 'The system reads the WAL from beginning to end and re-executes each logged operation in order: creating an empty hash index, then processing each write/update sequentially to rebuild the complete index state.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is replaying the WAL slower than having the data already in memory?',
  answer: 'Replaying requires reading from disk (slower than RAM), processing each operation sequentially (O(n) where n is the number of operations), and rebuilding all hash index structures from scratch rather than using the existing in-memory data.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How does using a WAL introduce a performance trade-off?',
  answer: 'The WAL provides durability but adds overhead: every write must be recorded to disk before completing, which is slower than pure in-memory operations. This sacrifices some write speed for data safety.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

# Section F – Range Query Limitations (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is a range query in the context of databases?',
  answer: 'A range query retrieves all records where a field\'s value falls between two boundaries, such as "all names between A and B" or "all IDs from 1000 to 2000".',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What would a naïve range query require the database to do when using a hash index?',
  answer: 'The database would need to either: 1) check every possible key value between the boundaries (infinite for strings), or 2) iterate through all entries in the hash map checking each one (O(n) scan).',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is iterating through all possible key values between A and B infeasible?',
  answer: 'There are infinite possible strings between any two string boundaries (e.g., "A", "AA", "AAA", "AAAA"...). Even for finite ranges, the number of possibilities would be astronomical.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What property of binary search trees allows them to support range queries?',
  answer: 'Binary search trees maintain sorted order through their structure invariant (left < parent < right). This ordering allows efficiently finding range start points and iterating through all values in the range.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

# Section G – Trade-offs & Use Cases (Additional)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is the hash index ideal for small datasets but inappropriate for large, persistent databases?',
  answer: 'Small datasets fit in RAM allowing fast O(1) operations. Large databases exceed RAM capacity, making hash indexes impractical due to cost and physical memory limits. Additionally, large databases often need range queries which hash indexes cannot support.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why is "keeping everything in memory" both a strength and a weakness?',
  answer: 'Strength: RAM allows extremely fast O(1) random access without mechanical delays. Weakness: RAM is volatile (data loss risk), expensive (cost constraint), and limited in capacity (size constraint).',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What happens to performance if the hash index does not fit entirely in RAM?',
  answer: 'The system must page parts of the index to disk (swapping), causing frequent disk I/O. This defeats the purpose of the hash index, degrading performance to potentially worse than a full table scan.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What trade-offs exist between hash indexes and tree-based indexes?',
  answer: 'Hash indexes: O(1) operations, no range queries, must fit in RAM. Tree indexes: O(log n) operations, support range queries, work well on disk. Hash is faster for point lookups but less versatile.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What is the fundamental difference in how hash indexes and tree indexes organize keys?',
  answer: 'Hash indexes scatter keys randomly via hash function, destroying order for O(1) access. Tree indexes maintain sorted order through hierarchical structure, enabling O(log n) access with range query support.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

# Section H – Integrative / Higher-Level Thinking

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How does the combination of RAM + WAL achieve both speed and durability?',
  answer: 'RAM provides fast O(1) access for reads and writes. WAL provides durability by persisting operations to disk sequentially. Together, they give in-memory speed with disk-backed reliability, though write latency increases slightly.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does this hash index design reveal about trade-offs in system design generally?',
  answer: 'It demonstrates the fundamental principle that you cannot optimize all dimensions simultaneously. Speed (RAM), durability (disk), cost (memory price), capacity (RAM limits), and functionality (range queries) all compete, requiring deliberate trade-off decisions.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How might SSDs change the performance profile of hash indexes?',
  answer: 'SSDs have no mechanical movement, making random access much faster than hard drives. This could make disk-based hash indexes more viable, though still slower than RAM. The scattered distribution would be less problematic.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What does the term "random access" mean in "Random Access Memory"?',
  answer: 'Random access means you can directly jump to any memory location in constant time, regardless of where it is. This contrasts with sequential access where you must read through previous data first.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Why does random access matter for hash index lookups?',
  answer: 'Hash functions produce random output distributions, so lookups require jumping to arbitrary locations in the array. Random access memory makes this O(1), while on disk it requires slow mechanical seeks.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What risk would you face if the WAL became corrupted?',
  answer: 'You could not rebuild the hash index after a crash, leading to permanent data loss. Corrupted WAL entries might also cause incorrect index reconstruction, leading to data inconsistency.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How might a database system mitigate the risk of WAL corruption?',
  answer: 'Strategies include: checksums for each WAL entry to detect corruption, redundant WAL copies on different disks, periodic snapshots of the index state, and RAID for disk redundancy.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'How could you combine multiple index types to balance performance and range-query support?',
  answer: 'Use hash indexes for frequently queried single keys (O(1) lookups) and tree-based indexes for fields requiring range queries (O(log n) with range support). Each field can have the appropriate index type.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'What lessons from hash index design generalize to broader system architecture?',
  answer: 'Key lessons: no free lunch in optimization; speed vs durability trade-offs; cost of flexibility (range queries); importance of understanding workload patterns; value of hybrid approaches; and that constraints (RAM size) drive design choices.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

# Section I – Synthesis / Design-Level Questions

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Design a small example table and explain how its hash index would map names to addresses.',
  answer: 'Example: Table has rows for Jordan, Shaq, Donald. Hash function h("Jordan")=4, h("Shaq")=4, h("Donald")=7. Hash index would store: index[4] → linked list of (Jordan, disk_addr_100) and (Shaq, disk_addr_250); index[7] → (Donald, disk_addr_175). Lookups hash the name and follow the chain if needed.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Explain step-by-step what happens when a new row is inserted into a hash-indexed table.',
  answer: '1) Extract the indexed key from the new row. 2) Write the operation to WAL on disk. 3) Hash the key to get array index. 4) Check for collision at that index. 5) Store key and row location (or row) using chaining/probing. 6) Complete the insert. WAL write ensures durability.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Explain step-by-step how a read query (WHERE name = \'Jordan\') would execute using a hash index.',
  answer: '1) Hash "Jordan" to get array index (e.g., 4). 2) Jump to index 4 in hash map O(1). 3) If collision, traverse chain/probe until finding "Jordan". 4) Retrieve disk address from hash map value. 5) Read row from that disk location. 6) Return result.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Describe how the system recovers the hash index after a crash.',
  answer: '1) Detect that hash index is missing from RAM (system restarted). 2) Create new empty hash map in memory. 3) Open WAL file from disk. 4) Read each operation sequentially from start. 5) Re-execute each operation (insert/update/delete) to rebuild index state. 6) Mark WAL as replayed. Index is now restored.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Suppose a hash index uses chaining for collisions. Show how two keys with the same hash would be stored.',
  answer: 'If hash("Jordan")=4 and hash("Shaq")=4, then index[4] would contain a linked list: Node1(key="Jordan", value=addr_100) → Node2(key="Shaq", value=addr_250). Lookup would hash the key, jump to index 4, then traverse the list comparing keys until match found.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Suppose a range query is performed on a hash index — describe the algorithm and its cost.',
  answer: 'Algorithm: Iterate through every entry in the hash map array, checking if each key falls within the range boundaries, collecting matching entries. Cost: O(n) where n is total number of entries, as we must examine every single entry. This is no better than a full table scan.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Suggest one possible improvement to make hash indexes more durable without slowing them down as much.',
  answer: 'Batch WAL writes: accumulate multiple operations in memory and flush them to disk together, reducing per-operation disk overhead. Trade-off: risk losing recent operations if crash occurs before flush, but can tune batch size for acceptable risk/performance balance.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Suggest how caching could reduce disk I/O in a hash index design.',
  answer: 'Cache recently accessed rows in memory alongside the index. When index returns disk address, check cache first before disk read. Use LRU eviction. This makes frequently accessed rows available in O(1) without disk I/O, improving read latency for hot data.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Design a hybrid index structure combining hash maps for equality and trees for ranges.',
  answer: 'Maintain two indexes per field: 1) Hash index for equality lookups (WHERE id=100) with O(1) access. 2) B-tree index for range queries (WHERE id BETWEEN 100 AND 200) with O(log n) + O(k) traversal. Query optimizer selects appropriate index based on query type.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Explain how you could benchmark hash index performance in a simulated database.',
  answer: 'Create test workload: 1) Generate dataset of known size. 2) Implement hash index and baseline (full scan). 3) Run equality queries measuring latency and throughput. 4) Vary dataset size to observe O(1) vs O(n) scaling. 5) Test collision handling under high load factor. 6) Measure WAL write overhead. 7) Test recovery time from WAL.',
  points: 5,
  answer_size: 'long',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: hash_indexes,
  content: 'Reflect: what does this hash index design teach about the engineering principle of "no free lunch" in optimization?',
  answer: 'Every optimization has trade-offs. Hash indexes gain O(1) speed but lose range queries, durability (needs WAL), and capacity (RAM limits). You cannot simultaneously optimize speed, flexibility, cost, and capacity. Good design requires understanding workload requirements and making conscious trade-offs rather than seeking a universal solution.',
  points: 5,
  answer_size: 'long',
  question_type: 'written'
)

puts "    ✓ Created 61 Hash Indexes written questions"

