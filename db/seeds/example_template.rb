# Example Exam Template
# This creates a sample template to demonstrate the system

puts "Creating example exam template..."

# Find some topics and questions
system_design = Topic.find_by(name: "System Design")
physics = Topic.find_by(name: "Physics")

if system_design && system_design.questions.any?
  template = ExamTemplate.create!(
    name: "Database Fundamentals Midterm",
    description: "Standard midterm exam format for database internals and indexing",
    duration_minutes: 120
  )
  
  # Section 1: Multiple Choice (30 minutes, 20 questions)
  section1 = template.exam_sections.create!(
    name: "Section A: Multiple Choice",
    position: 0,
    question_count: 10,
    duration_minutes: 30,
    question_type_filter: ['multiple_choice']
  )
  
  # Add source rule for System Design topic
  section1.section_source_rules.create!(
    source_type: 'Topic',
    source_id: system_design.id,
    weight: 1
  )
  
  # Section 2: Written Questions (60 minutes, 8 questions)
  section2 = template.exam_sections.create!(
    name: "Section B: Written Response",
    position: 1,
    question_count: 5,
    duration_minutes: 60,
    question_type_filter: ['written']
  )
  
  section2.section_source_rules.create!(
    source_type: 'Topic',
    source_id: system_design.id,
    weight: 1
  )
  
  # Section 3: Problem Solving (30 minutes, 3 composite questions)
  section3 = template.exam_sections.create!(
    name: "Section C: Problem Solving",
    position: 2,
    question_count: 3,
    duration_minutes: 30,
    question_type_filter: ['composite']
  )
  
  section3.section_source_rules.create!(
    source_type: 'Topic',
    source_id: system_design.id,
    weight: 1
  )
  
  puts "✓ Created template: #{template.name}"
  puts "  - #{template.exam_sections.count} sections"
  puts "  - #{template.total_questions} total questions"
  puts "  - #{template.total_duration} minutes"
end

puts "Done!"

