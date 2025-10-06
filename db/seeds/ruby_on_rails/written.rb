# frozen_string_literal: true

programming = Topic.find_by!(name: 'Ruby on Rails')
rails_guides = Source.find_by(name: 'Rails Guides')

puts '  - Rails written questions...'

Question.create!(
  topic: programming,
  source: rails_guides,
  source_reference: 'Active Record Basics',
  content: 'Explain the difference between has_many and belongs_to associations in Rails.',
  answer: 'belongs_to defines the relationship from the side that holds the foreign key (the child record). has_many defines the relationship from the referenced side (the parent). For example: a Comment belongs_to :post (comment has post_id), while a Post has_many :comments (post is referenced by multiple comments).',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: programming,
  content: 'Describe the purpose of database migrations in Rails and explain why they are important.',
  answer: 'Migrations are version control for your database schema. They allow you to modify database structure incrementally using Ruby code rather than SQL. They are reversible, reproducible across environments, tracked in version control, database-agnostic, and keep schema changes synchronized across the team.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: programming,
  source: rails_guides,
  content: 'Explain what the asset pipeline does in Rails and why it is useful.',
  answer: 'The asset pipeline concatenates, minifies, and fingerprints CSS and JavaScript files. Benefits include fewer HTTP requests (concatenation), smaller file sizes (minification), better caching (fingerprinting), preprocessing support (SCSS, CoffeeScript), and an organized asset structure.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: programming,
  content: 'Outline the main steps in the Rails request lifecycle from HTTP request to response.',
  answer: '1. Rack receives the HTTP request and passes it to Rails. 2. The router matches the request to a controller action. 3. The controller runs callbacks, loads data, and executes the action. 4. The action renders a view (or redirects), combining it with the layout. 5. The middleware stack finalizes headers and body before the response is returned to the web server.',
  points: 4,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: programming,
  content: 'Explain the purpose of database indexes and trade‑offs when overusing them.',
  answer: 'Indexes speed up reads at the cost of extra writes and storage. Overuse can slow insert/update performance and increase maintenance overhead.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

