# frozen_string_literal: true

puts 'Creating AI Engineering - Foundation Models topic...'

source = Source.find_or_create_by!(name: 'AI Engineering by Chip Huyen') do |s|
  s.source_type = 'book'
  s.notes = 'AI Engineering textbook by Chip Huyen (2024)'
end

topic = Topic.create!(name: 'AI Engineering - Foundation Models')

puts '  Creating modules...'

training_data = TopicModule.create!(
  topic: topic,
  name: 'Training Data',
  description: 'pp. 121-135',
  position: 1
)

model_architecture = TopicModule.create!(
  topic: topic,
  name: 'Model Architecture',
  description: 'pp. 135-151',
  position: 2
)

model_size_scaling = TopicModule.create!(
  topic: topic,
  name: 'Model Size and Scaling',
  description: 'pp. 151-168',
  position: 3
)

post_training = TopicModule.create!(
  topic: topic,
  name: 'Post-Training',
  description: 'pp. 169-187',
  position: 4
)

sampling_generation = TopicModule.create!(
  topic: topic,
  name: 'Sampling and Generation',
  description: 'pp. 187-206',
  position: 5
)

structured_outputs = TopicModule.create!(
  topic: topic,
  name: 'Structured Outputs',
  description: 'pp. 206-218',
  position: 6
)

hallucination = TopicModule.create!(
  topic: topic,
  name: 'Hallucination',
  description: 'pp. 218-231',
  position: 7
)

puts "  Created #{topic.topic_modules.count} modules"

puts '  Creating learning objectives...'

# Section 1: Training Data (LOs 1-8)
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 1, description: 'Identify Common Crawl as the dominant training data source for foundation models, and describe its quality problems -- clickbait, misinformation, propaganda -- citing the Washington Post study that found low-NewsGuard-ranked sites among the 1,000 most common websites in the dataset. State that despite these issues, Common Crawl is used in most models that disclose their data sources, including GPT-3 and Gemini.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 2, description: 'State that English accounts for 45.88% of Common Crawl, making it eight times more prevalent than Russian (5.97%), the second-most common language. Define low-resource languages as those not reaching 1% of Common Crawl, and interpret Table 2-2 to compare under-representation ratios: Punjabi at 231.5 versus English at 0.40.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 3, description: 'Interpret Figure 2-1 (GPT-4 MMLU by language) and Figure 2-2 (GPT-4 math performance): state that GPT-4 solves English math problems over three times more often than Armenian or Farsi, and fails all six questions for Burmese and Amharic. Identify that the three worst-performing languages on MMLU -- Telugu, Marathi, Punjabi -- are also among the most under-represented in Common Crawl.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 4, description: 'Explain three reasons why translating all queries to English and back is not a viable solution: (a) it requires a model already good enough at the under-represented language, (b) translation causes information loss (e.g. Vietnamese relationship pronouns collapse to "I" and "you"), (c) models can behave unexpectedly in non-English languages.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 5, description: 'Calculate the tokenisation cost disparity using the MASSIVE dataset: median token length is 7 in English, 32 in Hindi, and 72 in Burmese. State that the same content in Burmese costs approximately ten times more and takes ten times longer than in English on a per-token-priced API.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 6, description: 'Interpret Figure 2-3 (domain distribution of C4) and Table 2-3 (Open CLIP versus CLIP performance). State the principle that training data composition can matter as much as architecture, citing Open CLIP achieving comparable performance to CLIP with different data curation.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 7, description: 'State that smaller models trained on high-quality data can outperform larger models, citing Gunasekar et al. (2023): a 1.3B-parameter model trained on 7B tokens of curated coding data outperformed much larger models on several coding benchmarks.')
LearningObjective.create!(topic: topic, topic_module: training_data, category: 'Training Data', category_order: 1, position: 8, description: 'Name at least three language-specific foundation models and the languages they target: ChatGLM (Chinese), CroissantLLM (French), PhoGPT (Vietnamese), Jais (Arabic).')

# Section 2: Model Architecture (LOs 9-16)
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 9, description: 'Describe the two problems with the seq2seq architecture that the transformer was designed to solve: (a) the decoder generates output using only the final hidden state of the input (an information bottleneck), (b) RNN-based sequential processing makes it slow for long sequences.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 10, description: 'State that the attention mechanism predates the transformer by three years: Google used it with seq2seq in their 2016 GNMT model. The transformer paper (Vaswani et al., 2017) showed that attention could be used without RNNs.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 11, description: 'Distinguish the two phases of transformer inference: prefill (input tokens processed in parallel, creating key and value vectors) and decode (output tokens generated sequentially, one at a time). Explain why the sequential output bottleneck remains.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 12, description: 'Trace the attention mechanism computation using query, key, and value vectors: state the scaled dot-product attention formula Attention(Q, K, V) = softmax(QK^T / sqrt(d))V, and explain that a high dot-product score means the model uses more of that token\'s value vector.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 13, description: 'Explain multi-headed attention using Llama 2-7B: hidden dimension 4096, 32 attention heads, so each K, V, Q vector is split into 32 vectors of dimension 128. State that multiple heads allow the model to attend to different groups of previous tokens simultaneously.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 14, description: 'Describe the two modules within a transformer block: (a) the attention module, (b) the MLP module. Identify the four key dimension values that determine a transformer model\'s size -- model dimension, number of transformer blocks, feedforward dimension, vocabulary size.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 15, description: 'Describe the embedding module and the output/unembedding layer. Use Figure 2-6 to trace how tokens flow through the full architecture.')
LearningObjective.create!(topic: topic, topic_module: model_architecture, category: 'Model Architecture', category_order: 2, position: 16, description: 'Compare the transformer, Mamba, and Jamba architectures. State that Mamba-3B outperforms same-size transformers with linear scaling. State that Jamba has 52B total parameters (12B active) and fits in a single 80GB GPU.')

# Section 3: Model Size and Scaling (LOs 17-30)
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 17, description: 'Calculate the minimum GPU memory for inference from a model\'s parameter count: 7B parameters x 2 bytes (16 bits) = 14GB. State that the number of parameters can be misleading for sparse models.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 18, description: 'Explain the mixture-of-experts (MoE) architecture using Mixtral 8x7B: eight experts sharing some parameters gives 46.7B total; only two experts active per token per layer, yielding 12.9B active parameters.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 19, description: 'State that newer-generation models tend to outperform older, larger models: Llama 3-8B (2024) outperforms Llama 2-70B (2023) on MMLU.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 20, description: 'Distinguish between dataset tokens, training tokens, and epochs: if a 1-trillion-token dataset is trained for two epochs, the training tokens equal 2 trillion. State the Llama progression: 1.4T, 2T, 15T.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 21, description: 'Distinguish FLOPs (floating point operations, measuring a task\'s compute requirement) from FLOP/s (floating point operations per second, measuring a machine\'s peak performance).')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 22, description: 'Calculate the training time and cost for GPT-3-175B: 3.14 x 10^23 FLOPs, 256 H100s, approximately 236 days at peak capacity, exceeding $4 million at 70% utilisation.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 23, description: 'State the three numbers that signal a model\'s scale: number of parameters (proxy for learning capacity), number of training tokens (proxy for how much learned), number of FLOPs (proxy for training cost).')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 24, description: 'State the Chinchilla scaling law: for compute-optimal training, the number of training tokens should be approximately 20 times the model\'s parameter count. State the derivation: 400 models from 70M to 16B parameters on 5 to 500B tokens.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 25, description: 'Interpret Figure 2-8 to explain that training loss, optimal parameter count, and optimal token count can all be predicted from the compute budget.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 26, description: 'Explain why Llama\'s developers deliberately chose smaller models than the Chinchilla-optimal size: smaller models are easier to work with and cheaper to run inference on, driving wider adoption.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 27, description: 'Define scaling extrapolation as predicting optimal hyperparameters for large models from smaller ones. State that emergent abilities limit extrapolation accuracy.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 28, description: 'Describe the Inverse Scaling Prize: 99 submissions, 11 third prizes, no second or first prizes. State the finding: larger models sometimes worse on memorisation tasks and tasks with strong priors.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 29, description: 'Interpret Figure 2-9 showing training dataset size growth outpaces new data generation. State two consequences: proprietary data becomes a competitive advantage, and data restrictions are increasing.')
LearningObjective.create!(topic: topic, topic_module: model_size_scaling, category: 'Model Size and Scaling', category_order: 3, position: 30, description: 'State the electricity bottleneck: data centres consume 1-2% of global electricity, estimated to reach 4-20% by 2030, limiting growth to ~50 times. Describe the AI-generated data contamination concern.')

# Section 4: Post-Training (LOs 31-39)
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 31, description: 'State the purpose of post-training: addressing models optimised for text completion not conversation, and outputs that can be harmful. Post-training uses only ~2% of total compute.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 32, description: 'Trace the three-phase training pipeline (pre-training, SFT, preference finetuning) using Figure 2-10, and map each phase to the Shoggoth meme (Figure 2-11).')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 33, description: 'Demonstrate why SFT is needed using the "How to make pizza" example. Define SFT as behaviour cloning using demonstration data -- (prompt, response) pairs.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 34, description: 'Interpret Figure 2-12 (InstructGPT prompt distribution) and describe quality requirements for demonstration data. State that InstructGPT used 13,000 pairs costing approximately $130,000.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 35, description: 'Compare three approaches to obtaining SFT data: (a) OpenAI paid labellers, (b) LAION volunteers (90% male), (c) DeepMind heuristic dialogue filtering.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 36, description: 'Explain why preference finetuning uses comparison data rather than pointwise scoring. Describe the comparison format (prompt, winning_response, losing_response).')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 37, description: 'State the logistics and cost of comparison data: 3-5 minutes per comparison, $3.50 per comparison vs $25 per written response, approximately 73% inter-labeller agreement.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 38, description: 'Write the RLHF reward model loss function: -E[log(sigma(r_theta(x, y_w) - r_theta(x, y_l)))], identifying each term.')
LearningObjective.create!(topic: topic, topic_module: post_training, category: 'Post-Training', category_order: 4, position: 39, description: 'Distinguish RLHF from DPO: RLHF trains a separate reward model then optimises with PPO; DPO directly optimises from comparison data without a reward model. State that Meta switched from RLHF to DPO.')

# Section 5: Sampling and Generation (LOs 40-50)
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 40, description: 'Define greedy sampling as always picking the token with the highest probability. Explain why it works for classification but produces boring, repetitive outputs for generation.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 41, description: 'Trace the computation from input to next-token probabilities: input -> logit vector -> softmax -> probability distribution. Write the softmax formula.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 42, description: 'Calculate the effect of temperature on sampling: at T=1 probabilities are [0.27, 0.73]; at T=0.5 they shift to [0.12, 0.88]. T=0 is argmax. 0.7 is recommended for creative use cases.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 43, description: 'Define logprobs as probabilities on a log scale. Explain why log scale is preferred: it reduces the underflow problem when vocabularies are ~100K tokens.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 44, description: 'Explain top-k sampling: select the k tokens with the highest logits, compute softmax over only these k values. K typically ranges from 50 to 500.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 45, description: 'Distinguish top-p (nucleus) sampling from top-k: top-p dynamically selects the smallest set of tokens whose cumulative probability exceeds p (commonly 0.9-0.95).')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 46, description: 'State the stopping condition trade-off: fixed max tokens risks cutting off mid-sentence; stop tokens risk malformatted structured outputs.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 47, description: 'Explain how a sequence\'s probability is calculated as the product of per-token probabilities. State that dividing by sequence length (average logprob) avoids bias towards shorter sequences.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 48, description: 'State that a verifier boosted a 100M-parameter model to match a 3B-parameter model (Cobbe et al., 2021). Cite DeepMind (Snell et al., 2024) on test-time compute efficiency.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 49, description: 'Interpret Figure 2-19: sampling more outputs improves performance up to approximately 400, after which performance decreases. Contrast with Brown et al. (2024) log-linear improvement to 10,000.')
LearningObjective.create!(topic: topic, topic_module: sampling_generation, category: 'Sampling and Generation', category_order: 5, position: 50, description: 'Describe three methods for selecting the best output from multiple candidates: (a) highest average logprob, (b) reward model scoring, (c) self-consistency / majority voting.')

# Section 6: Structured Outputs (LOs 51-56)
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 51, description: 'Distinguish the two scenarios requiring structured outputs: (a) tasks that inherently need structured output (semantic parsing), and (b) tasks whose outputs are consumed by downstream apps requiring parseable formats.')
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 52, description: 'Compare five approaches to structured outputs -- prompting, post-processing, test time compute, constrained sampling, and finetuning -- classifying the first three as bandages and the last two as intensive treatment.')
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 53, description: 'Describe LinkedIn\'s defensive YAML parser: post-processing increased correctly formatted outputs from 90% to 99.99%. State LinkedIn\'s rationale for choosing YAML over JSON.')
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 54, description: 'Explain constrained sampling using Figure 2-21: at each generation step, the logit vector is filtered to keep only grammar-valid tokens. Name frameworks: guidance, outlines, instructor, llama.cpp.')
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 55, description: 'Describe the classifier head approach (Figure 2-22): appending a classification layer to the base model guarantees outputs are restricted to pre-specified classes.')
LearningObjective.create!(topic: topic, topic_module: structured_outputs, category: 'Structured Outputs', category_order: 6, position: 56, description: 'Define model inconsistency in two forms: same input producing different outputs, and slightly different input producing drastically different outputs. List mitigations: caching, fixing temperature/top-p/top-k, fixing the random seed.')

# Section 7: Hallucination (LOs 57-63)
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 57, description: 'Cite the June 2023 law firm case as evidence that hallucination is a critical problem. State that hallucination in text generation was first documented in 2016 (Goyal et al.).')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 58, description: 'Explain the self-delusion hypothesis (Ortega et al., DeepMind, 2021): the model cannot differentiate between data it is given and data it generates.')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 59, description: 'Interpret Figures 2-24 and 2-25 as examples of self-delusion: initial misidentification cascades into consistent but wrong answers.')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 60, description: 'Describe DeepMind\'s two mitigation techniques for self-delusion: (a) RL to differentiate observations from actions, (b) supervised learning with factual and counterfactual signals.')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 61, description: 'Explain the knowledge mismatch hypothesis: SFT teaches the model to mimic labeller responses drawing on knowledge the model does not possess, effectively training it to hallucinate.')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 62, description: 'Interpret Figure 2-26: RLHF made hallucination worse compared to SFT alone, even though human labellers overall preferred the RLHF model.')
LearningObjective.create!(topic: topic, topic_module: hallucination, category: 'Hallucination', category_order: 7, position: 63, description: 'Classify the two hallucination hypotheses as complementary. State two prompting-based mitigations: instructing the model to answer truthfully and requesting concise responses.')

puts "  Created #{topic.learning_objectives.count} learning objectives"
puts "  Topic: #{topic.name}"
