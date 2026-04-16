# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models diagram_label...'

# Item 3a (LO 3)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 128-129',
  content: 'Examine Figure 2-1 (GPT-4 MMLU performance by language). Label the following on the figure: (1) The language with the highest MMLU performance, (2) Three languages with the worst performance, (3) The approximate performance ratio between English and the worst-performing languages, (4) One language from South Asia that appears in the bottom quartile, (5) The general trend the figure demonstrates.',
  answer: '(1) English. (2) Telugu, Marathi, Punjabi. (3) Approximately 3x or greater. (4) Any of Telugu, Marathi, or Punjabi. (5) Performance degrades as language representation in training data decreases.',
  points: 5,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-1-000.png',
    'labels' => [
      'Language with highest MMLU performance',
      'Three languages with worst performance',
      'Performance ratio English vs worst-performing',
      'South Asian language in bottom quartile',
      'General trend demonstrated'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 3)

# Item 6a (LO 6)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 132-134',
  content: 'Examine Figure 2-3 (C4 domain distribution from the Washington Post analysis). Label: (1) the type of chart displayed, (2) two of the largest domain categories visible, (3) the general finding about domain diversity, (4) what "C4" stands for in this context.',
  answer: '(1) Bar chart / pie chart / domain distribution chart. (2) Any two visible top domains. (3) A small number of domains dominate the dataset. (4) Colossal Clean Crawled Corpus.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-3-000.png',
    'labels' => [
      'Type of chart displayed',
      'Two of the largest domain categories',
      'General finding about domain diversity',
      'What C4 stands for'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 6)

# Item 9a (LO 9)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 136-138',
  content: 'Examine Figure 2-4 (seq2seq vs transformer architecture contrast). Label: (1) the seq2seq encoder component, (2) the information bottleneck point (final hidden state), (3) the transformer self-attention mechanism, (4) one key difference in how information flows between the two architectures.',
  answer: '(1) Encoder (RNN/LSTM). (2) The single vector between encoder and decoder. (3) Self-attention / multi-head attention block. (4) Transformer allows direct connections between all positions; seq2seq channels through a single vector.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-4-000.png',
    'labels' => [
      'Seq2seq encoder component',
      'Information bottleneck point (final hidden state)',
      'Transformer self-attention mechanism',
      'Key difference in information flow'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 9)

# Item 12b (LO 12)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 139-142',
  content: 'Using Figure 2-5 (scaled dot-product attention illustration), label: (1) the Query vector input, (2) the Key vector input, (3) the Value vector input, (4) the scaling operation (divide by sqrt(d_k)).',
  answer: '(1) Q. (2) K. (3) V. (4) Scale / sqrt(d_k) division.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-5-000.png',
    'labels' => [
      'Query vector input (Q)',
      'Key vector input (K)',
      'Value vector input (V)',
      'Scaling operation: divide by sqrt(d_k)'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 12)

# Item 15b (LO 15)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 144-146',
  content: 'Using Figure 2-6 (token flow through full transformer architecture), label: (1) the embedding layer, (2) the positional embedding, (3) the stack of transformer blocks, (4) the unembedding/output layer.',
  answer: '(1) Embedding matrix. (2) Positional embedding. (3) Transformer blocks / layers. (4) Unembedding / output projection.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-6-000.png',
    'labels' => [
      'Embedding layer',
      'Positional embedding',
      'Stack of transformer blocks',
      'Unembedding / output layer'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 15)

# Item 16b (LO 16)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 148-151',
  content: 'Using Figure 2-7 (transformer vs Mamba vs Jamba comparison), label: (1) the transformer architecture, (2) the Mamba architecture, (3) the Jamba hybrid architecture, (4) the direction of compute scaling (linear vs quadratic) for each.',
  answer: '(1) Transformer architecture. (2) Mamba architecture. (3) Jamba hybrid architecture. (4) Transformer: quadratic; Mamba: linear; Jamba: hybrid/linear-dominant.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-7-000.png',
    'labels' => [
      'Transformer architecture',
      'Mamba architecture',
      'Jamba hybrid architecture',
      'Compute scaling direction (linear vs quadratic) for each'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 16)

# Item 25a (LO 25)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 161-162',
  content: 'Examine Figure 2-8 (compute budget vs training loss). Label: (1) the x-axis (compute budget), (2) the y-axis (training loss), (3) the key finding (training loss is predictable from compute budget).',
  answer: '(1) Compute budget. (2) Training loss. (3) Predictable / monotonic relationship between compute and loss.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-8-000.png',
    'labels' => [
      'X-axis: compute budget',
      'Y-axis: training loss',
      'Key finding: training loss predictable from compute budget'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 25)

# Item 29a (LO 29)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 165-167',
  content: 'Examine Figure 2-9 (Villalobos et al. data growth). Label: (1) the trend showing dataset size growth, (2) the trend showing new data generation, (3) the implication of the gap between these trends.',
  answer: '(1) Dataset growth trend (steeper). (2) New data generation trend (shallower). (3) Data will become scarcer as demand outpaces supply; proprietary data becomes a competitive advantage.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-9-000.png',
    'labels' => [
      'Trend: dataset size growth',
      'Trend: new data generation',
      'Implication of the gap between the two trends'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 29)

# Item 32b (LO 32)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 171-172',
  content: 'Using Figure 2-10 (three-phase training pipeline), label each phase and its data source.',
  answer: 'Pre-training (internet data), SFT (demonstration data), Preference finetuning (comparison data).',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-10-000.png',
    'labels' => [
      'Phase 1 and its data source',
      'Phase 2 and its data source',
      'Phase 3 and its data source'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 32)

# Item 34a (LO 34)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 174-177',
  content: 'Examine Figure 2-12 (InstructGPT prompt distribution by task type). Label: (1) at least two visible task type categories, (2) the approximate share of the largest category, (3) the general finding about task diversity, (4) an observation about whether the distribution is uniform or skewed.',
  answer: '(1) Accept any correctly labelled task types from the figure. (2) Approximate percentage of the largest visible category. (3) Tasks are diverse; no single task dominates entirely. (4) The distribution is skewed -- a small number of categories have larger shares.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-12-000.png',
    'labels' => [
      'At least two visible task type categories',
      'Approximate share of the largest category',
      'General finding about task diversity',
      'Observation: uniform or skewed distribution'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 34)

# Item 41d (LO 41)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 189-191',
  content: 'Using Figures 2-14 (probability distribution) and 2-15 (logit vector), label: (1) the logit vector showing one value per token, (2) the softmax operation, (3) the resulting probability distribution, (4) the relationship between logit magnitude and probability.',
  answer: '(1) Logit vector with one score per vocabulary token. (2) Softmax operation converting logits to probabilities. (3) Probability distribution (values 0-1, summing to 1). (4) Higher logit = higher probability after softmax.',
  points: 4,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-14-000.png',
    'labels' => [
      'Logit vector (one value per token)',
      'Softmax operation',
      'Resulting probability distribution',
      'Relationship between logit magnitude and probability'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 41)

# Item 42b (LO 42)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 191-195',
  content: 'Using Figure 2-16 (temperature effect on output distribution), label: (1) the low-temperature distribution (sharp peak), (2) the high-temperature distribution (flat), (3) the direction of increasing temperature.',
  answer: '(1) Low temperature: sharp, peaked distribution. (2) High temperature: flat, uniform-like distribution. (3) Increasing temperature moves distribution from sharp to flat.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-16-000.png',
    'labels' => [
      'Low-temperature distribution (sharp peak)',
      'High-temperature distribution (flat)',
      'Direction of increasing temperature'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 42)

# Item 43b (LO 43)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 195-196',
  content: 'Using Figure 2-17, label each step of the logit-to-logprob workflow.',
  answer: 'Logits -> Softmax -> Probabilities -> Log transformation -> Logprobs.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-17-000.png',
    'labels' => [
      'Step 1: Logits',
      'Step 2: Softmax',
      'Step 3: Probabilities',
      'Step 4: Log transformation',
      'Step 5: Logprobs'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 43)

# Item 45a (LO 45)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 197-199',
  content: 'Using Figure 2-18, label: (1) the 90% cumulative probability threshold, (2) the tokens included at 90% (yes, maybe), (3) the tokens included at 99% (yes, maybe, no).',
  answer: '(1) 90% cumulative probability threshold line. (2) Tokens included at top-p=0.90: "yes" and "maybe". (3) Tokens included at top-p=0.99: "yes", "maybe", and "no".',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-18-000.png',
    'labels' => [
      '90% cumulative probability threshold',
      'Tokens included at p=0.90 (yes, maybe)',
      'Tokens included at p=0.99 (yes, maybe, no)'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 45)

# Item 49a (LO 49)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 203-204',
  content: 'Using Figure 2-19, label: (1) the performance improvement region, (2) the approximate peak (~400 outputs), (3) the degradation region.',
  answer: '(1) Performance improvement region (left of peak). (2) Approximate peak at ~400 sampled outputs. (3) Performance degradation region (right of peak, adversarial outputs fool verifier).',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-19-000.png',
    'labels' => [
      'Performance improvement region',
      'Approximate performance peak (~400 outputs)',
      'Performance degradation region'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 49)

# Item 54b (LO 54)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 211-213',
  content: 'Using Figure 2-21, label: (1) the logit vector, (2) the grammar filter step, (3) the constrained sampling step.',
  answer: '(1) Full logit vector over vocabulary. (2) Grammar filter: masks out tokens that would produce invalid output. (3) Constrained sampling: selects next token from grammar-valid candidates only.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-21-000.png',
    'labels' => [
      'Logit vector',
      'Grammar filter step',
      'Constrained sampling step'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 54)

# Item 55a (LO 55)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 213-214',
  content: 'Using Figure 2-22, label: (1) the base model, (2) the classifier head layer, (3) the restricted output classes.',
  answer: '(1) Base language model (frozen or trainable). (2) Classifier head: linear layer appended to base model. (3) Restricted output classes (pre-specified labels only).',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-22-000.png',
    'labels' => [
      'Base model',
      'Classifier head layer',
      'Restricted output classes'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 55)

# Item 59a (LO 59)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 221-222',
  content: 'In Figure 2-24 (LLaVA-v1.5-7B), label: (1) the initial misidentification (shampoo -> milk), (2) the cascading error (listing milk as ingredient), (3) which hypothesis this illustrates.',
  answer: '(1) Shampoo bottle misidentified as milk. (2) Milk incorrectly listed as an ingredient in the cascading response. (3) Self-delusion hypothesis.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-24-000.png',
    'labels' => [
      'Initial misidentification (shampoo -> milk)',
      'Cascading error (milk listed as ingredient)',
      'Hypothesis illustrated (self-delusion)'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 59)

# Item 59c (LO 59)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 221-222',
  content: 'In Figure 2-25 (Zhang et al., 2023), label: (1) the initial incorrect assumption (9677 divisible by 13), (2) the cascading errors on subsequent questions, (3) the self-delusion mechanism at work.',
  answer: '(1) Initial incorrect assumption: 9677 treated as divisible by 13. (2) Subsequent questions answered incorrectly due to conditioning on the initial error. (3) Self-delusion: model conditions on its own generated fiction as if it were fact.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-25-000.png',
    'labels' => [
      'Initial incorrect assumption (9677 divisible by 13)',
      'Cascading errors on subsequent questions',
      'Self-delusion mechanism at work'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 59)

# Item 62a (LO 62)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 224-225',
  content: 'Using Figure 2-26 (InstructGPT data, Ouyang et al., 2022), label: (1) the RLHF model\'s hallucination rate, (2) the SFT model\'s hallucination rate, (3) which model performed worse on hallucination.',
  answer: '(1) RLHF hallucination rate (higher). (2) SFT hallucination rate (lower). (3) RLHF performed worse on hallucination despite higher human preference scores.',
  points: 3,
  question_type: 'diagram_label',
  options: {
    'image'  => 'fig2-26-000.png',
    'labels' => [
      'RLHF model hallucination rate',
      'SFT model hallucination rate',
      'Which model performed worse on hallucination'
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 62)
