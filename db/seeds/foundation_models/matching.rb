# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models matching...'

# Item 2c (LO 2) -- surplus right items require padded left
# Left: 5 languages; Right: 7 ratios (2 distractors)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 124-127',
  content: 'Match each language to its approximate under-representation ratio (ratio of world population share to Common Crawl share). Note: two items in the right column are distractors.',
  answer: 'English -> 0.40, Russian -> 1.20, Punjabi -> 231.5, Telugu -> 105.3, Hindi -> 45.2. Distractors: 5.97 (Russian\'s % share, not ratio) and 15.8 (fabricated).',
  points: 5,
  question_type: 'matching',
  options: {
    'left'  => ['English', 'Russian', 'Punjabi', 'Telugu', 'Hindi', '(distractor)', '(distractor)'],
    'right' => ['0.40', '1.20', '5.97', '15.8', '45.2', '105.3', '231.5']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 2)

# Item 8a (LO 8) -- 4 left, 6 right (2 distractors)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 131',
  content: 'Match each language-specific foundation model to its target language. Two items in the right column are distractors.',
  answer: 'ChatGLM -> Chinese, CroissantLLM -> French, PhoGPT -> Vietnamese, Jais -> Arabic. Distractors: Hindi, Japanese.',
  points: 4,
  question_type: 'matching',
  options: {
    'left'  => ['ChatGLM', 'CroissantLLM', 'PhoGPT', 'Jais', '(distractor)', '(distractor)'],
    'right' => ['Arabic', 'Chinese', 'French', 'Hindi', 'Japanese', 'Vietnamese']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 8)

# Item 14a (LO 14) -- 4 left, 6 right (2 distractors)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 143-147',
  content: 'Match each transformer dimension to its description. Two items in the right column are distractors.',
  answer: 'Model dimension -> Width of hidden representations throughout the model. Number of transformer blocks -> How many times the transformer block is repeated. Feedforward dimension -> Size of the MLP hidden layer within each block. Vocabulary size -> Number of unique tokens the model can process. Distractors: learning rate schedule parameter, maximum context window length.',
  points: 5,
  question_type: 'matching',
  options: {
    'left'  => ['Model dimension', 'Number of transformer blocks', 'Feedforward dimension', 'Vocabulary size', '(distractor)', '(distractor)'],
    'right' => [
      'Width of hidden representations throughout the model',
      'How many times the transformer block is repeated',
      'Size of the MLP hidden layer within each block',
      'Number of unique tokens the model can process',
      'The learning rate schedule parameter',
      'The maximum context window length'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 14)

# Item 16a (LO 16) -- 3 left, 6 right (Jamba maps to 2 properties; 2 are distractors)
# Restructure: each left item maps to exactly one right item; Jamba gets 2 correct answers
# Use 6 left entries (duplicate Jamba) to match 6 right entries
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 148-151',
  content: 'Match each architecture to its properties. Two properties are distractors. Note: Jamba matches two correct properties.',
  answer: 'Transformer -> Quadratic scaling with sequence length. Mamba -> Linear scaling with sequence length. Jamba -> 52B total / 12B active parameters. Jamba -> Fits in single 80GB GPU with 256K context. Distractors: Requires multiple GPUs for any context over 32K, Uses convolutional layers instead of attention.',
  points: 5,
  question_type: 'matching',
  options: {
    'left'  => ['Transformer', 'Mamba', 'Jamba', 'Jamba (also)', '(distractor)', '(distractor)'],
    'right' => [
      'Quadratic scaling with sequence length',
      'Linear scaling with sequence length',
      '52B total / 12B active parameters',
      'Fits in single 80GB GPU with 256K context',
      'Requires multiple GPUs for any context over 32K',
      'Uses convolutional layers instead of attention'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 16)

# Item 20a (LO 20) -- 3 left, 4 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 155-156',
  content: 'Match each term to its correct definition. One item in the right column is a distractor.',
  answer: 'Dataset tokens -> The number of unique tokens in the training corpus before repetition. Training tokens -> The total number of token-level training steps, including repetitions. Epoch -> One complete pass through the entire dataset. Distractor: The number of tokens processed per GPU per batch.',
  points: 3,
  question_type: 'matching',
  options: {
    'left'  => ['Dataset tokens', 'Training tokens', 'Epoch', '(distractor)'],
    'right' => [
      'One complete pass through the entire dataset',
      'The total number of token-level training steps, including repetitions',
      'The number of unique tokens in the training corpus before repetition',
      'The number of tokens processed per GPU per batch'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 20)

# Item 23a (LO 23) -- 3 left, 3 right (no distractors)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 158',
  content: 'Match each scale metric to what it serves as a proxy for.',
  answer: 'Number of parameters -> The model\'s learning capacity. Number of training tokens -> How much the model has learned. Number of FLOPs -> The cost of training.',
  points: 3,
  question_type: 'matching',
  options: {
    'left'  => ['Number of parameters', 'Number of training tokens', 'Number of FLOPs'],
    'right' => ['How much the model has learned', 'The model\'s learning capacity', 'The cost of training']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 23)

# Item 28c (LO 28) -- 3 left, 4 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-160',
  content: 'Match each Inverse Scaling Prize tier to its award amount and result. One item in the right column is a distractor.',
  answer: 'Third prize -> $5K -- 11 awarded. Second prize -> $20K -- none awarded. First prize -> $100K -- none awarded. Distractor: $50K -- 3 awarded.',
  points: 3,
  question_type: 'matching',
  options: {
    'left'  => ['Third prize', 'Second prize', 'First prize', '(distractor)'],
    'right' => [
      '$5K -- 11 awarded',
      '$20K -- none awarded',
      '$100K -- none awarded',
      '$50K -- 3 awarded'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 28)

# Item 32c (LO 32) -- 3 left, 3 right (no distractors)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 171-172',
  content: 'Match each Shoggoth meme layer (Figure 2-11) to its pipeline phase.',
  answer: 'Untamed monster -> Pre-training. Socially acceptable -> SFT. Smiley face -> Preference finetuning.',
  points: 3,
  question_type: 'matching',
  options: {
    'left'  => ['Untamed monster', 'Socially acceptable', 'Smiley face'],
    'right' => ['Pre-training', 'SFT', 'Preference finetuning']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 32)

# Item 35a (LO 35) -- 3 left, 4 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 177-178',
  content: 'Match each SFT data approach to its characteristics. One item in the right column is a distractor.',
  answer: 'OpenAI (InstructGPT) -> Paid high-quality labellers, college-educated, $10/pair. LAION (Open Assistant) -> 13,500 volunteers, 35 languages, 90% male demographic bias. DeepMind (Gopher) -> Heuristic dialogue filter matching [A]:/[B]: format. Distractor: API-based synthetic data generation from GPT-4.',
  points: 4,
  question_type: 'matching',
  options: {
    'left'  => ['OpenAI (InstructGPT)', 'LAION (Open Assistant)', 'DeepMind (Gopher)', '(distractor)'],
    'right' => [
      'Paid high-quality labellers, college-educated, $10/pair',
      '13,500 volunteers, 35 languages, 90% male demographic bias',
      'Heuristic dialogue filter matching [A]:/[B]: format',
      'API-based synthetic data generation from GPT-4'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 35)

# Item 38b (LO 38) -- 5 left, 6 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 184-185',
  content: 'Match each symbol in the RLHF reward model loss function to its meaning. One item in the right column is a distractor.',
  answer: 'rθ -> The reward model parameterised by θ. x -> The prompt. yw -> The winning response. yl -> The losing response. σ -> Sigmoid function. Distractor: The learning rate.',
  points: 5,
  question_type: 'matching',
  options: {
    'left'  => ['rθ', 'x', 'yw', 'yl', 'σ', '(distractor)'],
    'right' => [
      'Sigmoid function',
      'The prompt',
      'The winning response',
      'The losing response',
      'The reward model parameterised by θ',
      'The learning rate'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 38)

# Item 39a (LO 39) -- 4 left, 2 right (each maps multiple lefts to same right)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 185-187',
  content: 'Match each property or approach to the correct method: RLHF or DPO.',
  answer: 'Requires a separate reward model -> RLHF. Directly optimises from comparison data -> DPO. Meta\'s approach for Llama 2 -> RLHF. Meta\'s approach for Llama 3 -> DPO.',
  points: 4,
  question_type: 'matching',
  options: {
    'left'  => ["Requires a separate reward model", "Directly optimises from comparison data", "Meta's approach for Llama 2", "Meta's approach for Llama 3"],
    'right' => ['RLHF', 'DPO', 'RLHF', 'DPO']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 39)

# Item 45b (LO 45) -- 4 left, 2 right (each maps two lefts to same right)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 197-199',
  content: 'Match each property to top-k or top-p sampling.',
  answer: 'Fixed number of candidates regardless of probability distribution -> Top-k. Dynamic candidate set based on cumulative probability -> Top-p. Reduces softmax computation -> Top-k. Does not necessarily reduce softmax computation -> Top-p.',
  points: 4,
  question_type: 'matching',
  options: {
    'left'  => [
      'Fixed number of candidates regardless of probability distribution',
      'Dynamic candidate set based on cumulative probability',
      'Reduces softmax computation',
      'Does not necessarily reduce softmax computation'
    ],
    'right' => ['Top-k', 'Top-p', 'Top-k', 'Top-p']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 45)

# Item 50a (LO 50) -- 3 left, 4 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-206',
  content: 'Match each best-of-N selection method to its description. One item in the right column is a distractor.',
  answer: 'Highest average logprob -> Pick the response most fluent by the model\'s own estimate. Reward model scoring -> Score candidates with a trained evaluator model. Self-consistency / majority vote -> Select the answer given by the majority of candidates. Distractor: Pick the longest response.',
  points: 3,
  question_type: 'matching',
  options: {
    'left'  => ['Highest average logprob', 'Reward model scoring', 'Self-consistency / majority vote', '(distractor)'],
    'right' => [
      'Pick the response most fluent by the model\'s own estimate',
      'Score candidates with a trained evaluator model',
      'Select the answer given by the majority of candidates',
      'Pick the longest response'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 50)

# Item 52a (LO 52) -- 5 left, 2 right (each maps multiple lefts to same right)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 209-210',
  content: 'Match each structured output approach to whether it is a "bandage" or "treatment" for format compliance.',
  answer: 'Prompting -> Bandage. Post-processing -> Bandage. Test time compute -> Bandage. Constrained sampling -> Treatment. Finetuning -> Treatment.',
  points: 5,
  question_type: 'matching',
  options: {
    'left'  => ['Prompting', 'Post-processing', 'Test time compute', 'Constrained sampling', 'Finetuning'],
    'right' => ['Bandage', 'Bandage', 'Bandage', 'Treatment', 'Treatment']
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 52)

# Item 55b (LO 55) -- 2 left, 3 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 213-214',
  content: 'Match each finetuning approach to its characteristic. One item in the right column is a distractor.',
  answer: 'End-to-end finetuning -> Trains entire model, more resources, better performance. Head-only finetuning -> Freezes base model, trains only classification head, faster and cheaper. Distractor: Requires no training data at all.',
  points: 2,
  question_type: 'matching',
  options: {
    'left'  => ['End-to-end finetuning', 'Head-only finetuning', '(distractor)'],
    'right' => [
      'Trains entire model, more resources, better performance',
      'Freezes base model, trains only classification head, faster and cheaper',
      'Requires no training data at all'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 55)

# Item 63a (LO 63) -- 2 left, 3 right (1 distractor)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 225-226',
  content: 'Match each hallucination hypothesis to its causal mechanism. One item in the right column is a distractor.',
  answer: 'Self-delusion hypothesis -> Self-supervision causes hallucination (model conditions on its own generated errors). Knowledge mismatch hypothesis -> SFT causes hallucination (model mimics labeller knowledge it lacks). Distractor: Pre-training data causes hallucination (incorrect facts in Common Crawl).',
  points: 2,
  question_type: 'matching',
  options: {
    'left'  => ['Self-delusion hypothesis', 'Knowledge mismatch hypothesis', '(distractor)'],
    'right' => [
      'Self-supervision causes hallucination (model conditions on its own generated errors)',
      'SFT causes hallucination (model mimics labeller knowledge it lacks)',
      'Pre-training data causes hallucination (incorrect facts in Common Crawl)'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 63)
