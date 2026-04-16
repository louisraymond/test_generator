# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models multiple choice...'

# Item 1a (LO 1)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 121-123',
  content: 'Despite containing significant quality problems -- including clickbait, misinformation, and propaganda -- Common Crawl remains the dominant training data source for foundation models. What is the primary reason for this dominance?',
  answer: 'B - Common Crawl is freely available at unprecedented scale, making it the largest accessible text corpus.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Common Crawl data has been pre-filtered to remove low-quality content by a dedicated editorial team', 'correct' => false },
    { 'text' => 'Common Crawl is freely available at unprecedented scale, making it the largest accessible text corpus', 'correct' => true },
    { 'text' => 'Common Crawl data is curated by Google and verified against NewsGuard trustworthiness scores', 'correct' => false },
    { 'text' => 'Common Crawl only contains content from websites with high domain authority scores', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 1)

# Item 2a (LO 2) -- REVISED per final blueprint: misconception-targeted distractors
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 124-127',
  content: 'According to the chapter, what percentage of Common Crawl content is in English?',
  answer: 'C - 45.88% -- nearly half of the corpus despite English being one of thousands of languages.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '25.12% -- approximately equal to English speakers as a share of internet users', 'correct' => false },
    { 'text' => '35.50% -- approximately the share of English-language websites according to W3Techs', 'correct' => false },
    { 'text' => '45.88% -- nearly half of the corpus despite English being one of thousands of languages', 'correct' => true },
    { 'text' => '55.21% -- the majority share, reflecting English dominance of the internet overall', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 2)

# Item 4b (LO 4)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 129-130',
  content: 'ChatGPT-3.5 was tested on generating misinformation in both Chinese and English (NewsGuard, April 2023). Which result was found?',
  answer: 'D - The model generated misinformation in Chinese 7 out of 7 times but declined in English 6 out of 7 times.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The model refused to generate misinformation in both languages equally', 'correct' => false },
    { 'text' => 'The model generated misinformation more often in English than Chinese', 'correct' => false },
    { 'text' => 'The model generated misinformation in Chinese 3 out of 7 times and declined in English 5 out of 7 times', 'correct' => false },
    { 'text' => 'The model generated misinformation in Chinese 7 out of 7 times but declined in English 6 out of 7 times', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 4)

# Item 6c (LO 6)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 132-134',
  content: 'The comparison between Open CLIP and the original CLIP model demonstrates which principle?',
  answer: 'B - Training data composition can matter as much as model architecture for performance.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Larger models always outperform smaller models on image benchmarks', 'correct' => false },
    { 'text' => 'Training data composition can matter as much as model architecture for performance', 'correct' => true },
    { 'text' => 'Pre-training on Common Crawl produces better image models than curated datasets', 'correct' => false },
    { 'text' => 'The CLIP architecture is fundamentally flawed and requires redesign', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 6)

# Item 7a (LO 7)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 123',
  content: 'Gunasekar et al. (2023) demonstrated that a small model trained on high-quality data could outperform larger models. What were the model\'s specifications?',
  answer: 'B - 1.3B parameters trained on 7B tokens of curated coding data.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '7B parameters trained on 1.3B tokens of general web data', 'correct' => false },
    { 'text' => '1.3B parameters trained on 7B tokens of curated coding data', 'correct' => true },
    { 'text' => '13B parameters trained on 70B tokens of filtered Common Crawl', 'correct' => false },
    { 'text' => '130M parameters trained on 700M tokens of academic papers', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 7)

# Item 8b (LO 8)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 131',
  content: 'If you needed to build a Vietnamese chatbot, which existing language-specific foundation model would be most relevant to evaluate?',
  answer: 'C - PhoGPT.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'ChatGLM', 'correct' => false },
    { 'text' => 'CroissantLLM', 'correct' => false },
    { 'text' => 'PhoGPT', 'correct' => true },
    { 'text' => 'Jais', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 8)

# Item 9b (LO 9) -- REVISED per final blueprint: chapter-specific "book summary" rewrite
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 136-138',
  content: 'The chapter describes the seq2seq information bottleneck using an analogy. According to this analogy, what is the seq2seq decoder forced to do?',
  answer: 'D - Generate answers about a book using only a brief summary of the book.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Read the entire book simultaneously, losing track of individual chapters', 'correct' => false },
    { 'text' => 'Generate answers about a book using only the chapter headings', 'correct' => false },
    { 'text' => 'Process the book one word at a time, forgetting earlier words due to memory limits', 'correct' => false },
    { 'text' => 'Generate answers about a book using only a brief summary of the book', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 9)

# Item 10a (LO 10) -- REVISED per final blueprint: GNMT-specific
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 138',
  content: 'According to the chapter, Google used the attention mechanism with seq2seq in a production system before the transformer paper was published. What was this system, and when was it deployed?',
  answer: 'B - 2016, Google\'s Neural Machine Translation (GNMT) system.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '2014, Google\'s sequence-to-sequence translation model (Sutskever et al.)', 'correct' => false },
    { 'text' => '2016, Google\'s Neural Machine Translation (GNMT) system', 'correct' => true },
    { 'text' => '2015, Google\'s image captioning pipeline (Show, Attend and Tell)', 'correct' => false },
    { 'text' => '2018, BERT by Google', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 10)

# Item 11a (LO 11)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 138-139',
  content: 'During transformer inference, which statement correctly describes the two processing phases?',
  answer: 'C - Prefill processes all input tokens in parallel while decode generates output tokens sequentially.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Prefill processes tokens sequentially while decode processes them in parallel', 'correct' => false },
    { 'text' => 'Both prefill and decode process tokens sequentially, one at a time', 'correct' => false },
    { 'text' => 'Prefill processes all input tokens in parallel while decode generates output tokens sequentially', 'correct' => true },
    { 'text' => 'Prefill generates the output while decode refines it through multiple passes', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 11)

# Item 13c (LO 13) -- REVISED per final blueprint: distractor D replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 142-143',
  content: 'Why does multi-headed attention use multiple heads rather than a single large attention computation?',
  answer: 'B - Multiple heads allow the model to attend to different groups of tokens simultaneously.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Multiple heads reduce the total parameter count of the attention module', 'correct' => false },
    { 'text' => 'Multiple heads allow the model to attend to different groups of tokens simultaneously', 'correct' => true },
    { 'text' => 'Multiple heads eliminate the need for the scaling factor sqrt(d_k)', 'correct' => false },
    { 'text' => 'Multiple heads produce different-length output sequences in parallel, enabling faster generation', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 13)

# Item 16c (LO 16)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 148-151',
  content: 'Which architecture achieves inference computation that scales linearly with sequence length rather than quadratically?',
  answer: 'B - Mamba (state space model).',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Standard transformer (GPT-style)', 'correct' => false },
    { 'text' => 'Mamba (state space model)', 'correct' => true },
    { 'text' => 'BERT (encoder-only transformer)', 'correct' => false },
    { 'text' => 'Standard RNN/LSTM', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 16)

# Item 18a (LO 18) -- REVISED per final blueprint: options JSON updated with Psychometrician distractors
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 153-154',
  content: 'Why does Mixtral 8x7B have 46.7B total parameters rather than 56B (8 x 7B)?',
  answer: 'C - The experts share some parameters (embedding layers and other non-expert components), reducing the total.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Because each expert is a smaller model, they don\'t count toward the total parameter count', 'correct' => false },
    { 'text' => 'Mixtral uses lower-precision weights for some experts, reducing the effective count', 'correct' => false },
    { 'text' => 'The experts share some parameters (embedding layers and other non-expert components), reducing the total from the naive 8x7B calculation', 'correct' => true },
    { 'text' => 'Because only 2 experts are active, the other 6 experts\' parameters are pruned after training', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 18)

# Item 19a (LO 19) -- REVISED per final blueprint: distractors B and C replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 151',
  content: 'Which finding best illustrates that newer, smaller models can outperform older, larger ones?',
  answer: 'D - Llama 3-8B (2024) outperforms Llama 2-70B (2023) on MMLU.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'GPT-4 outperforms GPT-3 on all benchmarks', 'correct' => false },
    { 'text' => 'Llama 2-13B (2023) outperforms Llama 1-65B (2023) on most benchmarks', 'correct' => false },
    { 'text' => 'Chinchilla-70B outperformed Gopher-280B using the same compute budget', 'correct' => false },
    { 'text' => 'Llama 3-8B (2024) outperforms Llama 2-70B (2023) on MMLU', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 19)

# Item 20c (LO 20) -- REVISED per final blueprint: distractors with named misconceptions
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 155-156',
  content: 'RedPajama-v2 contains 30 trillion tokens. What is this roughly equivalent to in books?',
  answer: 'C - 450 million books -- far exceeding all books ever published.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '4.5 million books -- approximately the Library of Congress collection', 'correct' => false },
    { 'text' => '45 million books -- approximately all books ever published', 'correct' => false },
    { 'text' => '450 million books -- far exceeding all books ever published', 'correct' => true },
    { 'text' => '4.5 billion books -- more books than could physically exist', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 20)

# Item 21a (LO 21)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 157-158',
  content: 'What is the difference between FLOPs and FLOP/s?',
  answer: 'B - FLOPs measures a task\'s compute requirement; FLOP/s measures a machine\'s peak performance per second.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'FLOPs measures speed; FLOP/s measures total work', 'correct' => false },
    { 'text' => 'FLOPs measures a task\'s compute requirement; FLOP/s measures a machine\'s peak performance per second', 'correct' => true },
    { 'text' => 'FLOPs is used for training; FLOP/s is used for inference', 'correct' => false },
    { 'text' => 'They are the same thing; the notation difference is a common typo', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 21)

# Item 24a (LO 24)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-161',
  content: 'According to the Chinchilla scaling law, what is the optimal ratio of training tokens to parameters?',
  answer: 'C - 20 tokens per parameter.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '5 tokens per parameter', 'correct' => false },
    { 'text' => '10 tokens per parameter', 'correct' => false },
    { 'text' => '20 tokens per parameter', 'correct' => true },
    { 'text' => '100 tokens per parameter', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 24)

# Item 26a (LO 26)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 162-163',
  content: 'Why did Llama\'s developers choose a model size smaller than Chinchilla-optimal?',
  answer: 'B - Smaller models are cheaper to serve and drove wider adoption.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'They ran out of compute budget before reaching optimal size', 'correct' => false },
    { 'text' => 'Smaller models are cheaper to serve and drove wider adoption', 'correct' => true },
    { 'text' => 'The Chinchilla law had been disproven by the time Llama was trained', 'correct' => false },
    { 'text' => 'Regulatory requirements limited the maximum parameter count', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 26)

# Item 27a (LO 27) -- REVISED per final blueprint: distractor B replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 163-165',
  content: 'What limits the accuracy of predicting large-model behaviour from small-model experiments?',
  answer: 'C - Emergent abilities may only appear at scale and cannot be observed in small models.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Small models cannot learn any useful patterns', 'correct' => false },
    { 'text' => 'Small-scale hyperparameter sweeps are too coarse to transfer reliably to large models', 'correct' => false },
    { 'text' => 'Emergent abilities may only appear at scale and cannot be observed in small models', 'correct' => true },
    { 'text' => 'Small models use different training data than large models', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 27)

# Item 28a (LO 28)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-160',
  content: 'What was the key finding from the Inverse Scaling Prize competition?',
  answer: 'D - Larger models were sometimes worse on memorisation tasks and tasks with strong priors, but no submissions demonstrated real-world failures.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'All 99 submissions demonstrated real-world failures of large models', 'correct' => false },
    { 'text' => 'First-prize-winning tasks showed that large models always fail on complex reasoning', 'correct' => false },
    { 'text' => 'Larger models consistently outperformed smaller ones across all task types', 'correct' => false },
    { 'text' => 'Larger models were sometimes worse on memorisation tasks and tasks with strong priors, but no submissions demonstrated real-world failures', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 28)

# Item 30a (LO 30)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 167-168',
  content: 'According to the chapter, what are the two primary bottlenecks to continued scaling of AI training?',
  answer: 'B - Electricity consumption approaching physical limits and training data exhaustion/contamination.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'GPU memory limitations and cloud computing pricing', 'correct' => false },
    { 'text' => 'Electricity consumption approaching physical limits and training data exhaustion/contamination', 'correct' => true },
    { 'text' => 'Government regulation and talent shortage', 'correct' => false },
    { 'text' => 'Tokeniser vocabulary size and context window limitations', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 30)

# Item 31a (LO 31) -- REVISED per final blueprint: all distractors revised
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 169-171',
  content: 'Why does post-training use only ~2% of total compute yet have a large impact on model usability?',
  answer: 'C - The capabilities are latent from pre-training; post-training unlocks them using targeted, high-quality data.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Post-training replaces all pre-trained weights with better ones in 2% of the time', 'correct' => false },
    { 'text' => 'Post-training modifies only a small fraction of parameters using adapter layers, keeping 98% of the original model frozen', 'correct' => false },
    { 'text' => 'The capabilities are latent from pre-training; post-training unlocks them using targeted, high-quality data on a small fraction of the compute budget', 'correct' => true },
    { 'text' => 'Post-training uses a smaller, distilled version of the model that trains faster', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 31)

# Item 33a (LO 33)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 173-174',
  content: 'When given the prompt "How to make pizza," a pre-trained model might respond in several ways. Which response demonstrates why SFT is needed?',
  answer: 'D - The model adds context or asks follow-up questions instead of giving instructions.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The model gives clear step-by-step pizza instructions', 'correct' => false },
    { 'text' => 'The model refuses to answer due to safety filters', 'correct' => false },
    { 'text' => 'The model generates random tokens unrelated to pizza', 'correct' => false },
    { 'text' => 'The model adds context ("for a family of six?") or asks follow-up questions instead of giving instructions', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 33)

# Item 35b (LO 35)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 177-178',
  content: 'What is the primary demographic bias risk identified in LAION\'s volunteer-sourced SFT data (Kopf et al., 2023)?',
  answer: 'B - 90% of labellers identified as male.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '85% of volunteers were under age 25', 'correct' => false },
    { 'text' => '90% of labellers identified as male', 'correct' => true },
    { 'text' => 'Over 95% of contributions were in English only', 'correct' => false },
    { 'text' => '60% of volunteers had no college education', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 35)

# Item 37b (LO 37)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 182-184',
  content: 'What was the approximate inter-labeller agreement rate for preference comparisons at OpenAI?',
  answer: 'C - ~73%.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => '~50%', 'correct' => false },
    { 'text' => '~63%', 'correct' => false },
    { 'text' => '~73%', 'correct' => true },
    { 'text' => '~93%', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 37)

# Item 39b (LO 39) -- REVISED per final blueprint: distractor C replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 185-187',
  content: 'Why did Meta switch from RLHF (Llama 2) to DPO (Llama 3)?',
  answer: 'B - DPO eliminates the need for a separate reward model, reducing pipeline complexity.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'DPO produces higher-quality models than RLHF on all benchmarks', 'correct' => false },
    { 'text' => 'DPO eliminates the need for a separate reward model, reducing pipeline complexity', 'correct' => true },
    { 'text' => 'RLHF requires online RL training which is unstable and difficult to reproduce across runs', 'correct' => false },
    { 'text' => 'DPO requires significantly less comparison training data than RLHF', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 39)

# Item 40a (LO 40)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 188-189',
  content: 'For which task is greedy sampling (T=0) the most appropriate choice?',
  answer: 'A - Email spam classification requiring deterministic results.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Email spam classification requiring deterministic results', 'correct' => true },
    { 'text' => 'Creative marketing copy generation', 'correct' => false },
    { 'text' => 'Open-ended chatbot conversation', 'correct' => false },
    { 'text' => 'Poem writing with stylistic variety', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 40)

# Item 44a (LO 44)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 196-197',
  content: 'How does top-k sampling reduce computation compared to sampling from the full vocabulary?',
  answer: 'B - It computes softmax over only k tokens instead of the entire vocabulary, avoiding two full passes.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'It eliminates the need for the softmax function entirely', 'correct' => false },
    { 'text' => 'It computes softmax over only k tokens instead of the entire vocabulary, avoiding two full passes', 'correct' => true },
    { 'text' => 'It replaces softmax with a simpler linear normalisation', 'correct' => false },
    { 'text' => 'It uses a pre-computed lookup table for the top k tokens', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 44)

# Item 46a (LO 46) -- REVISED per final blueprint: distractors B and D replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 199-200',
  content: 'What is the primary risk of setting a fixed maximum token count that is too low?',
  answer: 'A - The output may be cut off mid-sentence or mid-structure, producing incomplete or unparseable responses.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'The output may be cut off mid-sentence or mid-structure, producing incomplete or unparseable responses', 'correct' => true },
    { 'text' => 'The model will attempt to summarise its response to fit within the limit, reducing output quality and completeness', 'correct' => false },
    { 'text' => 'The model will always generate exactly the maximum number of tokens, padding with filler text', 'correct' => false },
    { 'text' => 'The model will stop at a semantically meaningful point within the limit, masking the truncation from the user', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 46)

# Item 48a (LO 48)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 202-203',
  content: 'According to Cobbe et al. (2021), what size increase does a verifier provide in equivalent model performance?',
  answer: 'C - A 100M model matches a 3B model (approximately 30x).',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'A 100M model matches a 300M model (3x)', 'correct' => false },
    { 'text' => 'A 100M model matches a 1B model (10x)', 'correct' => false },
    { 'text' => 'A 100M model matches a 3B model (approximately 30x)', 'correct' => true },
    { 'text' => 'A 100M model matches a 30B model (300x)', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 48)

# Item 50b (LO 50) -- REVISED per final blueprint: distractor D replaced
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 204-206',
  content: 'For a factual QA system where answers can be verified against a database, which best-of-N selection method is most appropriate?',
  answer: 'C - Self-consistency / majority voting -- selects the answer most frequently generated across N samples.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Highest average logprob -- selects the most fluent response', 'correct' => false },
    { 'text' => 'Reward model scoring -- selects the response rated highest quality overall', 'correct' => false },
    { 'text' => 'Self-consistency / majority voting -- selects the answer most frequently generated across N samples', 'correct' => true },
    { 'text' => 'Select the longest response, as more detailed responses correlate with correctness for factual questions', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 50)

# Item 51a (LO 51)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 206-208',
  content: 'What distinguishes the two scenarios requiring structured outputs?',
  answer: 'B - One involves tasks that inherently need structured output, while the other involves wrapping natural language in a parseable format.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'One requires JSON and the other requires XML', 'correct' => false },
    { 'text' => 'One involves tasks that inherently need structured output (e.g., text-to-SQL), while the other involves wrapping natural language in a parseable format for downstream apps', 'correct' => true },
    { 'text' => 'One is for text generation and the other is for image generation', 'correct' => false },
    { 'text' => 'One uses constrained sampling and the other uses finetuning', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 51)

# Item 52c (LO 52)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 209-210',
  content: 'Which structured output approaches are classified as "bandages" (useful when the model is already mostly correct)?',
  answer: 'A - Prompting, post-processing, and test time compute.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Prompting, post-processing, and test time compute', 'correct' => true },
    { 'text' => 'Prompting, constrained sampling, and finetuning', 'correct' => false },
    { 'text' => 'Post-processing, constrained sampling, and test time compute', 'correct' => false },
    { 'text' => 'All five approaches are equally classified', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 52)

# Item 56a (LO 56)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 214-218',
  content: 'What are the two forms of model inconsistency?',
  answer: 'D - Same input producing different outputs, and slightly different inputs producing drastically different outputs.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Inconsistency between training and inference, and between different model sizes', 'correct' => false },
    { 'text' => 'Inconsistency between prompts in different languages, and between different APIs', 'correct' => false },
    { 'text' => 'Inconsistency between batch and single inference, and between GPU types', 'correct' => false },
    { 'text' => 'Same input producing different outputs, and slightly different inputs producing drastically different outputs', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 56)

# Item 57a (LO 57)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 218-219',
  content: 'What real-world incident demonstrated the critical risk of LLM hallucination in professional settings?',
  answer: 'B - A law firm was fined in June 2023 for submitting fictitious ChatGPT-generated legal research to court.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'A hospital AI prescribed the wrong medication dosage in 2022', 'correct' => false },
    { 'text' => 'A law firm was fined in June 2023 for submitting fictitious ChatGPT-generated legal research to court', 'correct' => true },
    { 'text' => 'A financial trading bot caused a flash crash due to hallucinated market data', 'correct' => false },
    { 'text' => 'An autonomous vehicle misinterpreted road signs due to LLM hallucination', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 57)

# Item 58b (LO 58)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 219-220',
  content: 'The self-delusion hypothesis was proposed by which research group?',
  answer: 'C - DeepMind (Ortega et al., 2021).',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'OpenAI (Ouyang et al., 2022)', 'correct' => false },
    { 'text' => 'UC Berkeley (Leo Gao, 2023)', 'correct' => false },
    { 'text' => 'DeepMind (Ortega et al., 2021)', 'correct' => true },
    { 'text' => 'Meta AI (Touvron et al., 2023)', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 58)

# Item 60a (LO 60)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 222',
  content: 'DeepMind proposed two techniques to mitigate self-delusion. Which pair is correct?',
  answer: 'B - RL to differentiate observations from actions, and supervised learning with factual/counterfactual signals.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Retrieval-augmented generation and chain-of-thought prompting', 'correct' => false },
    { 'text' => 'RL to differentiate observations from actions, and supervised learning with factual/counterfactual signals', 'correct' => true },
    { 'text' => 'Larger model size and longer context windows', 'correct' => false },
    { 'text' => 'Temperature reduction and constrained sampling', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 60)

# Item 61b (LO 61)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 223-224',
  content: 'Who proposed the knowledge mismatch hypothesis for hallucination?',
  answer: 'D - Leo Gao and John Schulman at UC Berkeley.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Ortega et al. at DeepMind', 'correct' => false },
    { 'text' => 'Ouyang et al. at OpenAI', 'correct' => false },
    { 'text' => 'Wei et al. at Google Brain', 'correct' => false },
    { 'text' => 'Leo Gao and John Schulman at UC Berkeley', 'correct' => true }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 61)

# Item 63b (LO 63)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 225-226',
  content: 'What are the two prompting-based mitigations for hallucination recommended in the chapter?',
  answer: 'C - Instructing the model to answer as truthfully as possible, and requesting concise responses.',
  points: 2,
  question_type: 'multiple_choice',
  options: [
    { 'text' => 'Chain-of-thought prompting and few-shot examples', 'correct' => false },
    { 'text' => 'System prompts and user prompts', 'correct' => false },
    { 'text' => 'Instructing the model to answer as truthfully as possible, and requesting concise responses', 'correct' => true },
    { 'text' => 'Adding retrieval context and increasing temperature', 'correct' => false }
  ]
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 63)
