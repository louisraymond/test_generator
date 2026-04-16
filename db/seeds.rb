# frozen_string_literal: true

# This file should ensure the data required to run the application can be loaded.
# For example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts '=' * 80
puts 'Starting seed process...'
puts '=' * 80

# Clear existing data in correct order
puts "\nClearing existing data..."
Question.destroy_all
  Exam.destroy_all
LearningObjective.destroy_all
Topic.destroy_all
  Source.destroy_all

# Create sources first (shared across topics)
load Rails.root.join('db/seeds/sources.rb')

# Load each topic directory
topic_dirs = [
  'thermal_quantum_physics',
  'physics_mosfets',
  'electronics_signal_processing',
  'theory_of_constraints',
  'ruby_on_rails',
  'this_codebase',
  'system_design',
  'foundation_models'
]

topic_dirs.each do |topic_dir|
  puts "\n" + ('-' * 80)
  puts "Loading #{topic_dir.titleize}..."
  puts ('-' * 80)
  
  topic_path = Rails.root.join('db/seeds', topic_dir)
  
  # Load topic definition first
  topic_file = topic_path.join('topic.rb')
  if File.exist?(topic_file)
    load topic_file
  else
    puts "  WARNING: Missing topic.rb for #{topic_dir}"
  end
  
  # Load question type files in a logical order
  question_types = %w[
    written
    calculation
    multiple_choice
    cloze
    matching
    ordering
    ranking
    diagram_label
    image_occlusion
    composite
  ]
  
  # Check if this topic has subdirectories (like system_design)
  subdirs = Dir.glob(topic_path.join('*/')).map { |d| File.basename(d) }
  
  if subdirs.any?
    # Load from subdirectories
    subdirs.sort.each do |subdir|
      subdir_path = topic_path.join(subdir)
      puts "  Loading #{subdir.titleize}..."
      
      question_types.each do |type|
        question_file = subdir_path.join("#{type}.rb")
        if File.exist?(question_file)
          load question_file
        end
      end
    end
  else
    # Load directly from topic directory
    question_types.each do |type|
      question_file = topic_path.join("#{type}.rb")
      if File.exist?(question_file)
        load question_file
      end
    end
  end
end

puts "\n" + ('=' * 80)
puts 'Seed process complete!'
puts '=' * 80
puts "\nSummary:"
puts "  Topics: #{Topic.count}"
puts "  Sources: #{Source.count}"
puts "  Learning Objectives: #{LearningObjective.count}"
puts "  Questions: #{Question.count}"
puts '=' * 80
