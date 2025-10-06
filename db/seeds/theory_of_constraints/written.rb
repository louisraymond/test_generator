# frozen_string_literal: true

toc = Topic.find_by!(name: 'Theory of Constraints')
goldratt = Source.find_by(name: 'The Goal by Eliyahu Goldratt')

puts '  - TOC written questions...'

Question.create!(
  topic: toc,
  source: goldratt,
  source_reference: 'Chapter 15',
  content: 'Define what is meant by a constraint in the Theory of Constraints.',
  answer: 'A constraint is anything that limits a system from achieving higher performance relative to its goal. It is the weakest link that determines the overall system throughput. In manufacturing, it is typically the resource (machine, process, or policy) with the least capacity relative to demand.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: toc,
  source: goldratt,
  source_reference: 'Chapter 20',
  content: 'Explain the Five Focusing Steps of the Theory of Constraints.',
  answer: '1. Identify the system constraint. 2. Exploit the constraint to get maximum output without major investment. 3. Subordinate everything else to support the constraint. 4. Elevate the constraint by increasing its capacity if needed. 5. Repeat once the constraint moves to maintain continuous improvement.',
  points: 5,
  answer_size: 'long',
  question_type: 'written'
)

Question.create!(
  topic: toc,
  content: 'Explain why local optimization can be harmful to overall system performance in TOC.',
  answer: 'Local optimization maximizes efficiency at non-constraint resources. This creates excess inventory when non-constraints produce faster than the constraint can process, wastes resources on improvements that do not increase throughput, and can starve the constraint if upstream processes optimize batch sizes instead of flow. Only improving the constraint increases system throughput.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: toc,
  content: 'Why can increasing local efficiency reduce system throughput?',
  answer: 'Non‑constraints can build inventory and starve the true constraint, lowering overall throughput despite local improvements.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

