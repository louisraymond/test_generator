# frozen_string_literal: true

puts 'Creating Maths - Exemplars (v1 sampler) topic...'

topic = Topic.create!(
  name: 'Maths - Exemplars (v1 sampler)',
  module_aims: [
    'Exercise every LaTeX rendering feature used across Louis\'s maths study',
    'Serve as a style reference for Claude-generated questions added later',
    'Span A-Level, STEP, undergraduate pure, stats, and ML content'
  ],
  learning_outcomes: [
    { 'title' => 'Rendering coverage', 'items' => [
      'Inline and display LaTeX renders cleanly',
      '\\begin{aligned}, \\begin{cases}, pmatrix, \\tag all supported',
      'Figures via markdown image syntax resolve and render',
      'Multi-part composite questions format with auto-lettered parts',
      'Mark-scheme working with **M1** / **A1** bold callouts renders'
    ] }
  ],
  syllabus_outline: [
    { 'title' => 'Breadth', 'items' => [
      'A-Level Pure (AQA style) — differentiation, integration, IBP',
      'STEP-style proof',
      'Linear algebra — matrices, eigenvalues',
      'Real analysis — ε-δ limits',
      'Complex numbers — polar form',
      'Statistics — Bayesian update, hypothesis testing',
      'Machine learning — gradient descent, cross-entropy',
      'Geometry — vectors (with figure)',
      'Numerical methods — Newton–Raphson',
      'Function notation (cloze recap)'
    ] }
  ],
  reference_links: [
    'AQA A-Level Maths past papers — https://www.physicsandmathstutor.com/maths-revision/a-level-aqa/papers/',
    'Cambridge STEP past papers — https://www.physicsandmathstutor.com/admissions/step/'
  ]
)

puts '  Creating modules...'

[
  ['Pure - Differentiation',        1],
  ['Pure - Integration',            2],
  ['Pure - Integration by parts',   3],
  ['STEP - Proof',                  4],
  ['Linear Algebra',                5],
  ['Real Analysis',                 6],
  ['Complex Numbers',               7],
  ['Probability & Statistics',      8],
  ['Machine Learning',              9],
  ['Geometry - Vectors',           10],
  ['Numerical Methods',            11],
  ['Function Notation (cloze)',    12]
].each do |name, position|
  TopicModule.create!(topic: topic, name: name, position: position, description: '')
end

puts "  ✓ Created topic #{topic.name} with #{topic.topic_modules.count} modules"
