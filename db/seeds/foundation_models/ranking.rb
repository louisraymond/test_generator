# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models ranking...'

# Item 39d (LO 39)
# Rank from simplest (1) to most complex (3) to implement
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 185-187',
  content: 'Rank the following preference optimisation approaches from simplest to most complex to implement (1 = simplest, 3 = most complex): RLHF with PPO, DPO, Reward model + best-of-N (no RL).',
  answer: 'DPO (simplest, rank 1) -> Reward model + best-of-N (rank 2) -> RLHF with PPO (most complex, rank 3).',
  points: 3,
  question_type: 'ranking',
  options: [
    { 'text' => 'RLHF with PPO', 'rank' => 3 },
    { 'text' => 'DPO', 'rank' => 1 },
    { 'text' => 'Reward model + best-of-N (no RL)', 'rank' => 2 }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 39)

# Item 52b (LO 52)
# Rank from least to most reliable (1 = least, 5 = most) for guaranteeing valid structured output
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 209-210',
  content: 'Rank the five structured output approaches from least to most reliable for guaranteeing valid structured output (1 = least reliable, 5 = most reliable): prompting, post-processing, test time compute, constrained sampling, finetuning.',
  answer: 'Prompting (least, rank 1) -> Post-processing (rank 2) -> Test time compute (rank 3) -> Finetuning (rank 4) -> Constrained sampling (most, rank 5). Note: constrained sampling vs finetuning ordering is debatable; accept either as most reliable.',
  points: 3,
  question_type: 'ranking',
  options: [
    { 'text' => 'Prompting', 'rank' => 1 },
    { 'text' => 'Post-processing', 'rank' => 2 },
    { 'text' => 'Test time compute', 'rank' => 3 },
    { 'text' => 'Constrained sampling', 'rank' => 5 },
    { 'text' => 'Finetuning', 'rank' => 4 }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 52)
