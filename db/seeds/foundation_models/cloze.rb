# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models cloze...'

# Item 1b (LO 1)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 121-123',
  content: 'Common Crawl\'s quality problems include [[clickbait]], [[misinformation]], and [[propaganda]]. Despite these issues, it is used in most models that disclose their data sources, including [[GPT-3]] and [[Gemini]]. The Washington Post study found that sites with low [[NewsGuard]] trustworthiness scores were among the 1,000 most common websites in the dataset.',
  answer: 'clickbait | misinformation | propaganda | GPT-3 | Gemini | NewsGuard',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 1)

# Item 2b (LO 2)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 124-127',
  content: 'English accounts for [[45.88]]% of Common Crawl, making it [[8]] times more prevalent than Russian (the second-most common language at [[5.97]]%). Punjabi\'s under-representation ratio (world population share to Common Crawl share) is [[231.5]], compared to English at 0.40.',
  answer: '45.88 | 8 | 5.97 | 231.5',
  points: 4,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 2)

# Item 4a (LO 4)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 129-130',
  content: 'Translation to English fails for three reasons: (a) it requires a model already [[good enough]] at the under-represented language, (b) translation causes [[information]] loss (e.g., Vietnamese [[relationship]] pronouns collapse to "I" and "you"), (c) models can behave [[unexpectedly]] in non-English languages.',
  answer: 'good enough | information | relationship | unexpectedly',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 4)

# Item 5a (LO 5)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 130-131',
  content: 'Using the MASSIVE dataset (Yennie Jun), the median token length for the same content is [[7]] in English, [[32]] in Hindi, and [[72]] in Burmese. This means Burmese costs approximately [[10]] times more than English on a per-token API.',
  answer: '7 | 32 | 72 | 10',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 5)

# Item 7b (LO 7)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 123',
  content: 'Gunasekar et al. (2023) trained a model with [[1.3B]] parameters on [[7B]] tokens of curated coding data, demonstrating it outperformed much larger models on several coding benchmarks.',
  answer: '1.3B | 7B',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 7)

# Item 9c (LO 9)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 136-138',
  content: 'In seq2seq, the decoder generates output using only the [[final]] hidden state of the input, creating an information [[bottleneck]] -- described as "like generating answers about a book using the book [[summary]]."',
  answer: 'final | bottleneck | summary',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 9)

# Item 10b (LO 10) -- REVISED per final blueprint: GNMT-specific cloze
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 138',
  content: 'The attention mechanism was used with seq2seq by [[Google]] in their [[GNMT]] model in [[2016]], three years before the transformer paper. The transformer paper showed attention could replace [[RNNs]], removing the need for sequential processing.',
  answer: 'Google | GNMT | 2016 | RNNs',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 10)

# Item 11b (LO 11)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 138-139',
  content: 'During the [[prefill]] phase, all input tokens are processed in [[parallel]], generating K and V vectors for all input tokens. During the [[decode]] phase, tokens are generated [[sequentially]], one at a time.',
  answer: 'prefill | parallel | decode | sequentially',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 11)

# Item 12a (LO 12)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 139-142',
  content: 'The scaled dot-product attention formula is: Attention(Q,K,V) = softmax(QK^T / [[sqrt(d_k)]])V, where the denominator prevents dot products from growing too [[large]] as dimension increases.',
  answer: 'sqrt(d_k) | large',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 12)

# Item 13a (LO 13)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 142-143',
  content: 'Llama 2-7B has a hidden dimension of [[4096]], with [[32]] attention heads, so each K, V, Q vector is split into vectors of dimension [[128]] (since 4096 / 32 = 128).',
  answer: '4096 | 32 | 128',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 13)

# Item 14c (LO 14)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 143-147',
  content: 'A Hugging Face config.json shows: hidden_size determines the [[model dimension]], num_hidden_layers determines the number of [[transformer blocks]], intermediate_size determines the [[feedforward]] dimension, and vocab_size determines how many unique [[tokens]] the model can process.',
  answer: 'model dimension | transformer blocks | feedforward | tokens',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 14)

# Item 17a (LO 17)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 151-153',
  content: 'To calculate minimum GPU memory for inference: [[7B]] parameters x [[2]] bytes (16-bit precision) = 14 GB.',
  answer: '7B | 2',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 17)

# Item 18b (LO 18)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 153-154',
  content: 'In Mixtral 8x7B, only [[2]] experts are active per token per layer, yielding [[12.9B]] active parameters. Cost and speed match a dense model of the same active size.',
  answer: '2 | 12.9B',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 18)

# Item 19b (LO 19)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 151',
  content: 'Llama 3-[[8B]] (2024) outperforms Llama 2-[[70B]] (2023) on MMLU, demonstrating that newer-generation models can beat older models that are [[~9x]] times larger.',
  answer: '8B | 70B | ~9x',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 19)

# Item 20b (LO 20)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 155-156',
  content: 'If a 1-trillion-token dataset is trained for 2 epochs, the training tokens equal [[2]] trillion. The Llama training data progression was: 1.4T (Llama 1) -> [[2]]T (Llama 2) -> 15T (Llama 3).',
  answer: '2 | 2',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 20)

# Item 21b (LO 21)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 157-158',
  content: 'FLOPs measures a task\'s [[compute]] requirement; FLOP/s measures a machine\'s [[peak]] performance. Warning: FLOPS looks similar to FLOPs but actually means [[FLOP/s]].',
  answer: 'compute | peak | FLOP/s',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 21)

# Item 22a (LO 22)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 158-159',
  content: 'GPT-3 training required [[3.14]] x 10^23 FLOPs. Using [[256]] H100 GPUs at 5.2 x 10^18 FLOPs/day, the training takes approximately [[236]] days at peak capacity.',
  answer: '3.14 | 256 | 236',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 22)

# Item 23b (LO 23)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 158',
  content: 'The three numbers that signal a model\'s scale are: parameters (proxy for [[learning capacity]]), training tokens (proxy for [[how much the model learned]]), and FLOPs (proxy for [[training cost]]).',
  answer: 'learning capacity | how much the model learned | training cost',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 23)

# Item 24b (LO 24)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-161',
  content: 'The Chinchilla scaling law states that training tokens should be approximately [[20]] times the parameter count. A 3B-parameter model needs approximately [[60B]] tokens for compute-optimal training.',
  answer: '20 | 60B',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 24)

# Item 27b (LO 27)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 163-165',
  content: 'A 2022 Microsoft/OpenAI paper transferred hyperparameters from a [[40M]]-parameter model to a [[6.7B]]-parameter model. However, [[emergent]] abilities (Wei et al., 2022) limit extrapolation accuracy.',
  answer: '40M | 6.7B | emergent',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 27)

# Item 28b (LO 28)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-160',
  content: 'The Inverse Scaling Prize offered $[[5]]K for third prize, $[[20]]K for second, and $[[100]]K for first. Of [[99]] submissions, [[11]] received third prizes, but no second or first prizes were awarded.',
  answer: '5 | 20 | 100 | 99 | 11',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 28)

# Item 30b (LO 30)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 167-168',
  content: 'Data centres consume [[1]]-[[2]]% of global electricity, estimated to reach [[4]]-[[20]]% by 2030, limiting growth to at most ~[[50]] times current levels.',
  answer: '1 | 2 | 4 | 20 | 50',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 30)

# Item 31b (LO 31)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 169-171',
  content: 'Post-training uses ~[[2]]% of total compute, with [[98]]% spent on pre-training. The two problems it addresses are: models optimised for [[text]] completion rather than conversation, and outputs that can be racist, sexist, or factually [[wrong]].',
  answer: '2 | 98 | text | wrong',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 31)

# Item 33b (LO 33)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 173-174',
  content: 'SFT is defined as [[behaviour]] cloning using demonstration data consisting of ([[prompt]], [[response]]) pairs.',
  answer: 'behaviour | prompt | response',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 33)

# Item 34c (LO 34)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 174-177',
  content: 'InstructGPT used [[13,000]] demonstration pairs. Approximately [[90]]% of labellers had at least a college degree. Each pair could cost up to $[[10]] and take up to [[30]] minutes. Total cost was approximately $[[130,000]].',
  answer: '13,000 | 90 | 10 | 30 | 130,000',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 34)

# Item 34e (LO 34) -- NEW per final blueprint: Table 2-6 reference
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 176-178',
  content: 'According to Table 2-6, approximately [[90]]% of InstructGPT labellers had at least a college degree, and each (prompt, response) pair could cost up to $[[10]] and take up to [[30]] minutes to produce.',
  answer: '90 | 10 | 30',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 34)

# Item 36a (LO 36)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 179-182',
  content: 'Individual scoring is unreliable: one labeller gives [[5]], another gives [[7]] for the same sample. Comparison data uses the format (prompt, [[winning]] response, [[losing]] response).',
  answer: '5 | 7 | winning | losing',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 36)

# Item 37a (LO 37)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 182-184',
  content: 'LMSYS found manual comparison takes [[3]]-[[5]] minutes per comparison. Scialom reported $[[3.50]] per comparison versus $[[25]] per written response. Inter-labeller agreement was approximately [[73]]%.',
  answer: '3 | 5 | 3.50 | 25 | 73',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 37)

# Item 38a (LO 38)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 184-185',
  content: 'The RLHF reward model loss function is: -E[log(sigma([[r_theta]](x, [[y_w]]) - [[r_theta]](x, [[y_l]]))], where r_theta is the [[reward]] model parameterised by theta.',
  answer: 'r_theta | y_w | r_theta | y_l | reward',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 38)

# Item 40b (LO 40)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 188-189',
  content: 'Greedy sampling always picks the token with the [[highest]] probability. It works well for [[classification]] tasks but produces boring, [[repetitive]] outputs for language generation.',
  answer: 'highest | classification | repetitive',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 40)

# Item 41b (LO 41)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 189-191',
  content: 'The softmax formula is: pi = e^[[xi]] / Sigma(e^[[xj]]). Logits do [[not]] sum to one and [[can]] be negative. Softmax converts them to valid [[probabilities]].',
  answer: 'xi | xj | not | can | probabilities',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 41)

# Item 42e (LO 42)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 191-195',
  content: 'Higher temperature [[flattens]] the distribution (more creative); lower temperature [[sharpens]] it (more consistent). T=0 is implemented as [[argmax]]. A value of [[0.7]] is often recommended for creative use cases.',
  answer: 'flattens | sharpens | argmax | 0.7',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 42)

# Item 44b (LO 44)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 196-197',
  content: 'Top-k selects the [[k]] tokens with the highest logits, then computes softmax over only these k values. K typically ranges from [[50]] to [[500]].',
  answer: 'k | 50 | 500',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 44)

# Item 46b (LO 46)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 199',
  content: 'A fixed maximum token count risks cutting off [[mid-sentence]]. Stop tokens risk malformatted structured outputs such as JSON missing [[closing]] brackets.',
  answer: 'mid-sentence | closing',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 46)

# Item 47b (LO 47)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-202',
  content: 'logprob("I love food") = logprob("I") + logprob("love" | "[[I]]") + logprob("food" | "[[I]], [[love]]"). Dividing by sequence [[length]] gives average logprob, avoiding bias toward [[shorter]] sequences.',
  answer: 'I | I | love | length | shorter',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 47)

# Item 53a (LO 53)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 211',
  content: 'LinkedIn\'s defensive YAML parser increased correctly formatted outputs from [[90]]% to [[99.99]]%. YAML was preferred over JSON because it is less [[verbose]] and requires fewer output [[tokens]].',
  answer: '90 | 99.99 | verbose | tokens',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 53)

# Item 56b (LO 56)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 214-218',
  content: 'Mitigations for model inconsistency include [[caching]], fixing temperature/top-p/top-k, and fixing the random [[seed]]. Even with all settings fixed, [[hardware]] differences can affect output.',
  answer: 'caching | seed | hardware',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 56)

# Item 57b (LO 57)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 218-219',
  content: 'Hallucination in text generation was first documented in [[2016]] by [[Goyal]] et al. The June 2023 law firm case involved submitting fictitious [[ChatGPT]]-generated legal research to court.',
  answer: '2016 | Goyal | ChatGPT',
  points: 2,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 57)

# Item 61a (LO 61)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 223-224',
  content: 'The knowledge mismatch hypothesis: SFT teaches the model to mimic labeller [[responses]] that draw on knowledge the model does not [[possess]], effectively training it to [[hallucinate]]. Schulman claims LLMs [[know]] whether they know something.',
  answer: 'responses | possess | hallucinate | know',
  points: 3,
  question_type: 'cloze',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 61)
