# frozen_string_literal: true

puts 'Creating This Codebase topic...'

codebase = Topic.create!(
  name: 'This Codebase'
)

puts '  Creating learning objectives...'

LearningObjective.create!(topic: codebase, category: 'Architecture', description: 'Understand the overall Rails MVC structure of the application', position: 1)
LearningObjective.create!(topic: codebase, category: 'Architecture', description: 'Explain the relationship between Topics, Learning Objectives, and Questions', position: 2)
LearningObjective.create!(topic: codebase, category: 'Services', description: 'Describe the purpose and functionality of the ExamBuilder service', position: 3)
LearningObjective.create!(topic: codebase, category: 'Services', description: 'Explain how polymorphic question types are implemented', position: 4)
LearningObjective.create!(topic: codebase, category: 'Tools & Libraries', description: 'Identify the PDF generation library and its usage', position: 5)
LearningObjective.create!(topic: codebase, category: 'Tools & Libraries', description: 'Understand how SVG images are embedded inline', position: 6)

puts "  ✓ Created topic: #{codebase.name}"

