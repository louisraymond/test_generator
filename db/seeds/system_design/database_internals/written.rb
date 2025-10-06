# frozen_string_literal: true

system_design = Topic.find_by!(name: 'System Design')
database_internals = system_design.topic_modules.find_by!(name: 'Database Internals & Indexing')

puts '  - System Design written questions...'

# Database Internals & Indexing — Fundamentals (Questions 1-11)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What does it mean for data to be persistent in a computer system?',
  answer: 'Persistent data remains available even after power is lost or the system restarts.',
  points: 1,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: "Why can't RAM be used for persistent storage in databases?",
  answer: 'RAM is volatile — all data is erased when the computer shuts down.',
  points: 1,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why are databases typically stored on hard drives or SSDs rather than in RAM?',
  answer: 'Because disks and SSDs are non-volatile and retain information without power, providing long-term durability.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'In a typical database system, where is the data stored and how is it accessed?',
  answer: 'Data is stored on a non-volatile storage medium (e.g. hard drive or SSD) and accessed via database software running on the host machine.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What are the main physical components of a traditional hard drive?',
  answer: 'A rotating metallic platter, a moving read/write arm with a magnetic head, and a controller that positions the arm.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why does the physical location of data on a hard drive affect how quickly it can be read?',
  answer: 'The arm must physically move to reach sectors; greater distance between pieces of data means more movement and slower reads.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'What performance problem occurs if two related pieces of data are stored far apart on a hard drive?',
  answer: 'The read/write arm must move back and forth repeatedly, causing long seek times and slower performance.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'How can a database designer improve performance by controlling where related data is placed on disk?',
  answer: 'By storing related records contiguously, minimizing physical arm movement and allowing faster sequential reads.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why does the mechanical nature of a hard drive matter for database performance?',
  answer: 'Because physical motion is slow compared to electronic operations — reducing it is key to fast reads/writes.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'How can the layout of data on a disk be conceptualized in simple terms?',
  answer: 'As a large array of bytes — each position on disk corresponds to a specific byte or portion of a record.',
  points: 1,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: system_design,
  topic_module: database_internals,
  content: 'Why does storing related bytes close together improve performance?',
  answer: 'Because sequential reads of nearby bytes require fewer seeks and can be streamed efficiently.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

puts "  ✓ Created #{Question.where(topic: system_design, question_type: 'written').count} System Design written questions"

