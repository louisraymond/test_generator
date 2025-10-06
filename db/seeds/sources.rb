# frozen_string_literal: true

puts 'Creating sources...'

Source.create!(
  name: 'Feynman Lectures on Physics Vol. 2',
  source_type: 'book',
  notes: 'Classic physics textbook'
)

Source.create!(
  name: 'The Goal by Eliyahu Goldratt',
  source_type: 'book',
  notes: 'Business novel about TOC'
)

Source.create!(
  name: 'Rails Guides',
  source_type: 'documentation',
  notes: 'Official Rails documentation'
)

Source.create!(
  name: 'Wikimedia Commons',
  source_type: 'website',
  notes: 'Public domain / Creative Commons images; see individual file pages for license and attribution.'
)

Source.create!(
  name: 'Project Documentation',
  source_type: 'internal',
  notes: 'docs/app_exam.md in this repository'
)
