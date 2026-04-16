# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models calculation...'

# Item 5b (LO 5)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 130-131',
  content: 'The same semantic content requires 7 tokens in English and 72 tokens in Burmese. If an API charges $0.01 per 1,000 tokens, calculate: (a) the cost of processing this content in English, (b) the cost in Burmese, (c) the cost ratio. Show your work.',
  answer: '(a) 7/1000 x $0.01 = $0.00007. (b) 72/1000 x $0.01 = $0.00072. (c) Ratio = 72/7 = 10.29x (accept ~10x).',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 5)

# Item 5d (LO 5)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 130-131',
  content: 'Hindi requires 32 tokens for content that takes 7 English tokens. At $0.02 per 1K tokens, compute: (a) cost per query in English, (b) cost per query in Hindi, (c) cost ratio. Then: if 100,000 queries per day are Hindi, what is the daily cost difference compared to if those queries were in English?',
  answer: '(a) 7/1000 x $0.02 = $0.00014. (b) 32/1000 x $0.02 = $0.00064. (c) 32/7 = 4.57x. Daily difference: 100,000 x ($0.00064 - $0.00014) = $50/day.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 5)

# Item 12c (LO 12)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 139-142',
  content: 'Given Q = [1, 0], K = [0.5, 0.5], V = [1, 0], and d_k = 2: (a) Compute QK^T. (b) Compute QK^T / sqrt(d_k). (c) Apply softmax to get the attention weight. (d) State what a high attention weight means for the output.',
  answer: '(a) QK^T = 1*0.5 + 0*0.5 = 0.5. (b) 0.5 / sqrt(2) = 0.5/1.414 = 0.354. (c) softmax(0.354) = for single token, weight = 1.0. (d) A high weight means more of that token\'s value vector is used in generating the output.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 12)

# Item 13b (LO 13)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 142-143',
  content: 'A transformer model has hidden dimension 4096 and 32 attention heads. (a) Compute the per-head dimension. (b) If you deploy this model across 4 GPUs using tensor parallelism, how many heads per GPU? (c) Would 3-way parallelism work? Explain.',
  answer: '(a) 4096/32 = 128. (b) 32/4 = 8 heads per GPU. (c) 32/3 = 10.67, does not divide evenly. Most tensor parallelism frameworks will error.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 13)

# Item 13d (LO 13)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 142-143',
  content: 'You are deploying a model with 48 attention heads and hidden dimension 6144 across 6 GPUs using tensor parallelism. (a) Compute the per-head dimension. (b) Verify the heads divide evenly across 6 GPUs. (c) What is the minimum GPU count that divides 48 evenly?',
  answer: '(a) 6144/48 = 128. (b) 48/6 = 8 heads per GPU, divides evenly. (c) Factors of 48: 1, 2, 3, 4, 6, 8, 12, 16, 24, 48. Minimum meaningful GPU count = 2.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 13)

# Item 14d (LO 14)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 143-147',
  content: 'A model config shows: hidden_size=5120, num_hidden_layers=40, intermediate_size=13824, vocab_size=32000. Estimate the total parameter count and GPU memory required for 16-bit inference. Show your work.',
  answer: 'Attention per layer: ~4 x 5120^2 = ~105M. MLP per layer: ~2 x 5120 x 13824 = ~142M. Total per layer: ~247M. 40 layers: ~9.9B. Embedding: ~32K x 5120 = ~164M. Total: ~10B. Memory: 10B x 2 bytes = 20GB.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 14)

# Item 17b (LO 17)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 151-153',
  content: 'Calculate the minimum GPU memory required for inference of a 70B-parameter model at 16-bit precision. Will it fit on a single A100-80GB GPU?',
  answer: '70B x 2 bytes = 140 GB. No, it does not fit on a single A100-80GB (80 GB available). Requires at least 2x A100-80GB.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 17)

# Item 22b (LO 22) -- REVISED per final blueprint: cleaned model answer
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 158-159',
  content: 'GPT-3 training requires 3.14 x 10^23 FLOPs. You have 256 H100 GPUs producing 5.2 x 10^18 FLOPs/day collectively. (a) Compute training time at peak capacity. (b) At 70% utilisation, what is the actual training time? (c) At $2/H100/hour, what is the total cost?',
  answer: '(a) 3.14e23 / 5.2e18 = approximately 236 days at peak capacity (the 5.2e18 figure already accounts for 256 GPUs). (b) 236 / 0.7 = approximately 337 days. (c) 256 GPUs x $2/hr x 24 hr/day x 337 days = $4,128,768, approximately $4.13M.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 22)

# Item 24c (LO 24)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-161',
  content: 'Your compute budget is 10^23 FLOPs. Using the Chinchilla law (tokens = 20 x parameters) and the approximation FLOPs = 6 x N x D (where N = parameters, D = tokens): (a) Derive the relationship between FLOPs and N. (b) Solve for the optimal N. (c) Calculate the optimal D.',
  answer: '(a) D = 20N, so FLOPs = 6N(20N) = 120N^2. (b) N^2 = 10^23/120 = 8.33e20. N = sqrt(8.33e20) = ~28.9B. (c) D = 20 x 28.9B = ~578B tokens.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 24)

# Item 37c (LO 37)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 182-184',
  content: 'You need 10,000 preference comparisons for a DPO run. Budget: $50K. Using $3.50/comparison and 4 min average per comparison, calculate: (a) total cost, (b) total labelling hours, (c) time with 10 labellers at 20 hr/week.',
  answer: '(a) 10,000 x $3.50 = $35,000. (b) 10,000 x 4 min = 40,000 min = 667 hours. (c) 667 / (10 x 20) = 3.3 weeks.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 37)

# Item 41c (LO 41)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 189-191',
  content: 'Given logits [2.1, 1.9, -5.0] for a 3-class problem, compute the softmax probabilities for each class. Are classes 0 and 1 nearly tied?',
  answer: 'e^2.1 = 8.17, e^1.9 = 6.69, e^-5.0 = 0.0067. Sum = 14.87. P(0) = 0.55, P(1) = 0.45, P(2) = 0.0004. Yes, classes 0 and 1 are nearly tied.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 41)

# Item 42a (LO 42)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 191-195',
  content: 'Two tokens A and B have logits [1, 2]. Compute probabilities at T=1 and T=0.5. Show the effect of temperature on the distribution.',
  answer: 'T=1: softmax([1,2]) = [e^1/(e^1+e^2), e^2/(e^1+e^2)] = [0.27, 0.73]. T=0.5: softmax([1/0.5, 2/0.5]) = softmax([2,4]) = [e^2/(e^2+e^4), e^4/(e^2+e^4)] = [0.12, 0.88]. Lower T sharpens the distribution.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 42)

# Item 47c (LO 47) -- REVISED per final blueprint: corrected model answer
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-202',
  content: "Three candidate responses have these per-token logprobs:\n- Response A (2 tokens): [-0.5, -0.3]\n- Response B (5 tokens): [-0.4, -0.2, -0.3, -0.1, -0.5]\n- Response C (3 tokens): [-0.2, -0.1, -0.4]\nCompute total logprob and average logprob for each. Which response wins under each method?",
  answer: 'Total logprob: A = -0.8; B = -1.5; C = -0.7. Total winner: C (least negative). Average logprob: A = -0.400; B = -0.300; C = -0.233. Average winner: C (least negative). C wins both methods.',
  points: 4,
  question_type: 'calculation',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 47)
