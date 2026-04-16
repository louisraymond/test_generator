# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models ordering...'

# Item 11c (LO 11)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 138-139',
  content: "Arrange the following transformer inference steps in the correct order:\n- Generate one output token\n- Append output token to context\n- Process all input tokens in parallel (prefill)\n- Store key/value vectors in KV cache\n- Repeat decode until stopping condition",
  answer: 'Process all input tokens in parallel (prefill) -> Store key/value vectors in KV cache -> Generate one output token -> Append output token to context -> Repeat decode until stopping condition',
  points: 3,
  question_type: 'ordering',
  options: [
    'Generate one output token',
    'Append output token to context',
    'Process all input tokens in parallel (prefill)',
    'Store key/value vectors in KV cache',
    'Repeat decode until stopping condition'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 11)

# Item 15a (LO 15)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 144-146',
  content: "Arrange the following steps in the order a token flows through a transformer model:\n- Unembedding layer maps to token probabilities\n- Token passes through N transformer blocks\n- Input token is converted to embedding vector\n- Positional embedding is added\n- Sampling selects the next token",
  answer: 'Input token is converted to embedding vector -> Positional embedding is added -> Token passes through N transformer blocks -> Unembedding layer maps to token probabilities -> Sampling selects the next token',
  points: 3,
  question_type: 'ordering',
  options: [
    'Unembedding layer maps to token probabilities',
    'Token passes through N transformer blocks',
    'Input token is converted to embedding vector',
    'Positional embedding is added',
    'Sampling selects the next token'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 15)

# Item 32a (LO 32) -- includes one distractor item
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 171-172',
  content: "Arrange the three phases of the training pipeline in the correct order. One item is a distractor that does not belong as a separate phase:\n- Preference finetuning\n- Reward model pre-training\n- Supervised finetuning (SFT)\n- Pre-training on internet data",
  answer: 'Pre-training on internet data -> Supervised finetuning (SFT) -> Preference finetuning. Distractor: "Reward model pre-training" (it is part of preference finetuning, not a separate pipeline phase).',
  points: 3,
  question_type: 'ordering',
  options: [
    'Preference finetuning',
    'Reward model pre-training',
    'Supervised finetuning (SFT)',
    'Pre-training on internet data'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 32)

# Item 41a (LO 41)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 189-191',
  content: "Arrange the computation pipeline in the correct order:\n- Probability distribution (each value between 0 and 1, sum to 1)\n- Logit vector (one value per vocabulary token)\n- Input tokens\n- Softmax function applied",
  answer: 'Input tokens -> Logit vector (one value per vocabulary token) -> Softmax function applied -> Probability distribution (each value between 0 and 1, sum to 1)',
  points: 3,
  question_type: 'ordering',
  options: [
    'Probability distribution (each value between 0 and 1, sum to 1)',
    'Logit vector (one value per vocabulary token)',
    'Input tokens',
    'Softmax function applied'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 41)

# Item 43a (LO 43)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 195-196',
  content: "Arrange the logprob workflow in the correct order:\n- Log transformation\n- Softmax function\n- Logprobs\n- Raw logits\n- Probabilities",
  answer: 'Raw logits -> Softmax function -> Probabilities -> Log transformation -> Logprobs',
  points: 3,
  question_type: 'ordering',
  options: [
    'Log transformation',
    'Softmax function',
    'Logprobs',
    'Raw logits',
    'Probabilities'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 43)

# Item 47a (LO 47)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-202',
  content: "Arrange the logprob summation concept in the correct order:\n- Average by dividing by sequence length\n- Sum individual logprobs\n- Compute per-token conditional logprobs\n- Compare sequence scores",
  answer: 'Compute per-token conditional logprobs -> Sum individual logprobs -> Average by dividing by sequence length -> Compare sequence scores',
  points: 3,
  question_type: 'ordering',
  options: [
    'Average by dividing by sequence length',
    'Sum individual logprobs',
    'Compute per-token conditional logprobs',
    'Compare sequence scores'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 47)

# Item 54a (LO 54)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 211-213',
  content: "Arrange the constrained sampling steps in the correct order:\n- Sample from valid tokens only\n- Generate logit vector for next token\n- Filter logits to grammar-valid tokens\n- Output structurally valid token",
  answer: 'Generate logit vector for next token -> Filter logits to grammar-valid tokens -> Sample from valid tokens only -> Output structurally valid token',
  points: 3,
  question_type: 'ordering',
  options: [
    'Sample from valid tokens only',
    'Generate logit vector for next token',
    'Filter logits to grammar-valid tokens',
    'Output structurally valid token'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 54)

# Item 58a (LO 58)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 219-220',
  content: "Arrange the self-delusion mechanism steps in the correct order:\n- Subsequent tokens are conditioned on generated fiction as if it were fact\n- Model generates an incorrect statement\n- Error snowballs through the rest of the response\n- Model cannot distinguish given data from generated data",
  answer: 'Model cannot distinguish given data from generated data -> Model generates an incorrect statement -> Subsequent tokens are conditioned on generated fiction as if it were fact -> Error snowballs through the rest of the response',
  points: 3,
  question_type: 'ordering',
  options: [
    'Subsequent tokens are conditioned on generated fiction as if it were fact',
    'Model generates an incorrect statement',
    'Error snowballs through the rest of the response',
    'Model cannot distinguish given data from generated data'
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 58)
