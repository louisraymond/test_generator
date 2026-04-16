# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models written...'

# Item 1c (LO 1)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 121-123',
  content: 'Your team at a health insurance company is using a foundation model to auto-generate member-facing FAQ answers about coverage policies. During QA, a reviewer notices the model occasionally produces plausible but incorrect claims about coverage limits. Given what you know about Common Crawl\'s quality composition, explain why a pre-trained model might confidently produce incorrect health coverage information (2-3 sentences). Then recommend one architectural mitigation that does not involve retraining (2-3 sentences).',
  answer: 'The model was pre-trained on Common Crawl, which includes low-quality health content (WebMD comment sections, supplement blogs, sites with low NewsGuard scores). The model learned to produce this content fluently, making health misinformation indistinguishable from accurate information in its output distribution. Mitigation: RAG over the company\'s actual coverage documents, instructing the model to only cite retrieved policy text.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 1)

# Item 2d (LO 2)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 124-131',
  content: 'Grab (Southeast Asia ride-hailing) is expanding its in-app AI assistant to handle Khmer, Lao, and Burmese. Using the under-representation ratio framework, explain why out-of-the-box GPT-4 performance will be poor for these languages (2-3 sentences). Then recommend whether to deploy GPT-4 directly, use a translation layer, or build language-specific models, with reasoning (2-3 sentences).',
  answer: 'All three languages have under-representation ratios exceeding 100x. The training data contains very little content in these languages, meaning the model has minimal capability. Translation layers fail for three reasons (requires existing capability, information loss, unexpected behaviour). Recommendation: language-specific models or finetuning on curated data, starting with Burmese (worst tokenisation cost at ~10x).',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 2)

# Item 3c (LO 3)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 128-129',
  content: 'An edtech startup in Pakistan is building a maths tutoring app using GPT-4 for Urdu-speaking students. The CTO assumes GPT-4 will perform comparably to its English maths capability. Using evidence from Figures 2-1 and 2-2, what should you tell the CTO? Propose a specific evaluation plan before launch.',
  answer: 'GPT-4 solves English math problems 3x+ more often than low-resource languages. Urdu is severely under-represented. Run GPT-4 on a curated set of Urdu math problems at target grade levels and measure accuracy. Expect significant degradation. Budget for a translation pipeline or Urdu finetuning.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 3)

# Item 4c (LO 4)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 129-130',
  content: 'A Korean enterprise SaaS company handles customer tickets by translating them to English, processing through an English-optimised LLM, and translating back. Korean tickets frequently use honorific verb forms indicating customer seniority and emotional state -- critical for support tier routing. Using the three failure modes for translation pipelines, explain why this architecture will lose critical information and propose an alternative.',
  answer: 'Korean honorifics collapse to neutral English pronouns (information loss). The translation model may not handle domain-specific Korean well (requires existing capability). Alternative: use a Korean-capable model or finetune on Korean support tickets with honorific metadata.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 4)

# Item 5c (LO 5)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 130-131',
  content: 'You are building the billing model for a multilingual LLM API. Product wants to charge $0.01 per 1K tokens. Analytics shows 30% of traffic is Hindi (32 median tokens) and 5% is Burmese (72 median tokens) for content that requires 7 English tokens. Finance asks for a margin analysis. Calculate the effective per-query cost for each language and recommend a pricing structure that preserves margin.',
  answer: 'English: 7 tokens = $0.00007/query. Hindi: 32 tokens = $0.00032/query (~4.6x). Burmese: 72 tokens = $0.00072/query (~10.3x). Per-token pricing preserves margin but Burmese users pay 10x. Per-query pricing absorbs cost difference. Recommendation: per-token pricing with language-specific cost disclosure, or tiered per-query pricing.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 5)

# Item 6d (LO 6)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 132-134',
  content: 'Your team at an agricultural AI company is debating strategy. The ML lead wants to develop a custom vision-transformer architecture for crop disease detection. The data lead wants to spend the same budget on curating 500K labelled crop disease images. Using the Open CLIP vs CLIP comparison, advise the VP of Engineering on which investment is more likely to improve detection performance.',
  answer: 'Open CLIP used the same ViT-B/32 architecture as CLIP but different data and outperformed on domain-specific benchmarks (Birdsnap 46.0 vs 37.8, Stanford Cars 79.3 vs 59.4). Data curation should be prioritised because crop disease images are rare in general training data; architecture novelty will not overcome data scarcity.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 6)

# Item 9d (LO 9)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 136-138',
  content: 'Explain the two problems with the seq2seq architecture that the transformer solved. For each problem, describe the mechanism that caused it and how the transformer\'s design addresses it. Reference Figure 2-4 in your explanation.',
  answer: '(1) Information bottleneck: the decoder only sees the final hidden state, losing information from earlier tokens. The transformer uses attention to allow the decoder to access all encoder positions directly. (2) Sequential processing: RNNs process tokens one at a time, making long sequences slow. The transformer processes all positions in parallel via self-attention.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 9)

# Item 11d (LO 11)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 138-139',
  content: 'You are the ML platform lead at a legal tech company. Your contract analysis pipeline has a 10-second latency SLA. Contracts average 50K tokens of input, and the model generates ~500 tokens of analysis. Users are complaining about timeouts. Your infra engineer says "the input is huge, we need more prefill throughput." Using the prefill/decode distinction, diagnose whether the bottleneck is more likely in prefill or decode. What optimisation would you prioritise?',
  answer: 'Prefill is parallel -- 50K tokens processed in one forward pass, relatively fast. Decode is sequential -- 500 tokens generated one at a time is the bottleneck. Optimise decode: KV-cache, speculative decoding, or shorter output targets.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 11)

# Item 12d (LO 12) -- REVISED per final blueprint: anchored to Figure 2-5 and Llama 2-7B
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 139-142',
  content: 'Using Figure 2-5 and the Llama 2-7B worked example from the chapter, explain what a high Q-K dot product score means for the output. Specifically: (a) describe what Q, K, and V represent in the context of Llama 2-7B\'s 32 attention heads, (b) explain why the output changes when one token has a much higher dot-product score than others, and (c) explain why the scaling factor sqrt(d_k) uses d_k = 128 for Llama 2-7B.',
  answer: '(a) In Llama 2-7B, the hidden dimension 4096 is split across 32 heads, giving each head Q, K, V vectors of dimension 128. Q represents the current token\'s "question"; K represents each other token\'s "label"; V represents the actual information content. (b) A high Q-K score means the model uses more of that token\'s V vector in the weighted sum. When one token dominates, its value vector dominates the output. (c) d_k = 128 because 4096/32 = 128. Without scaling by sqrt(128), the dot products would be too large, pushing softmax into near-zero or near-one regions.',
  points: 5,
  answer_size: 'long',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 12)

# Item 14b (LO 14) -- REVISED per final blueprint: anchored to Table 2-4
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 143-147',
  content: 'Using Table 2-4, compare the two modules within a transformer block between Llama 2-7B and Llama 3-8B. For each module (attention and MLP), state the key dimension values from both models and explain what changes between generations. Then explain how the four key dimensions (model dimension, number of blocks, feedforward dimension, vocabulary size) interact to determine total parameter count.',
  answer: 'From Table 2-4: Llama 2-7B has model dimension 4096, 32 blocks, feedforward dimension 11008, vocab 32000. Llama 3-8B has model dimension 4096, 32 blocks, feedforward dimension 14336, vocab 128256. Llama 3 increased feedforward from 11008 to 14336 and vocab from 32K to 128K. The four dimensions interact multiplicatively: each transformer block contains attention (~4 x model_dim^2) and MLP (~2 x model_dim x ff_dim) parameters, repeated across all blocks, plus embedding (vocab x model_dim).',
  points: 5,
  answer_size: 'long',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 14)

# Item 15c (LO 15)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 144-146',
  content: 'Explain why the number of position indices in the positional embedding matrix determines the model\'s maximum context length. What happens if you try to process an input longer than this limit? What are RoPE scaling and YaRN trying to solve?',
  answer: 'Each position in the input gets a unique positional embedding. If there are only N position indices, the model cannot represent position N+1. Inputs longer than N either get truncated or produce degraded output. RoPE scaling and YaRN extend the positional embedding to support longer contexts without retraining from scratch.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 15)

# Item 16d (LO 16)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 148-151',
  content: 'Your biotech startup processes genomic sequences averaging 500K tokens. Your current transformer model costs $200K/year on 8x A100-80GB. The CEO asks about switching to Mamba. Evaluate the switch: what is the expected compute benefit, and what is the main risk?',
  answer: 'Transformers scale quadratically; Mamba scales linearly. For 500K tokens, potentially 4-8x compute reduction. Main risk: linear scaling does not guarantee good long-context performance. Must benchmark on actual genomic data before committing.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 16)

# Item 17c (LO 17)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 151-153',
  content: 'Your team lead says "let\'s deploy Llama 3-70B on our 4x A100-40GB node." Calculate the minimum memory required at 16-bit. Will it fit on 160GB total? Explain why memory for model weights alone is not the complete picture.',
  answer: '70B x 2 = 140 GB. 4x A100-40GB = 160 GB. Only 20 GB left for KV-cache, activations, framework overhead. Dangerously tight for any reasonable batch size or context. Recommendation: 4x A100-80GB or quantise to 8-bit.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 17)

# Item 18c (LO 18)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 153-154',
  content: 'Your procurement team allocated GPUs for a "46.7B parameter model" after seeing Mixtral\'s specs. They provisioned 4x A100-80GB. Explain whether they over-provisioned, correctly provisioned, or under-provisioned, distinguishing memory requirements from compute requirements.',
  answer: 'Memory: 46.7B x 2 bytes = ~93 GB (all expert weights must be in memory). 2x A100-80GB suffices for weights. Compute/latency: matches 12.9B dense model (only 2 experts active). The team correctly sized for memory but over-provisioned for latency.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 18)

# Item 20d (LO 20)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 155-156',
  content: 'You are planning a continued pre-training run with 50B tokens of medical literature. A colleague says "let\'s train for 4 epochs to reach 200B training tokens." Distinguish dataset tokens from training tokens in this plan and evaluate the risk of 4 epochs.',
  answer: 'Dataset = 50B tokens. Training tokens = 50B x 4 = 200B. Risk: multiple epochs mean the model sees the same data repeatedly, increasing memorisation and overfitting. The Llama trend (1.4T -> 2T -> 15T) emphasises more unique data, not more epochs.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 20)

# Item 22c (LO 22)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 158-159',
  content: 'You are writing a budget proposal for pre-training a 13B-parameter model. You have 128 H100 GPUs at $2.50/H100/hour. The Chinchilla rule says you need 260B training tokens. Estimate timeline and cost, stating assumptions. Show your arithmetic.',
  answer: 'FLOPs ~ 6 x 13B x 260B = 2.03e22. Per-GPU: H100 ~1.98e15 FLOP/s = ~1.71e20/day. 128 GPUs = ~2.19e22/day. Training: ~0.93 days at peak. At 70% utilisation: ~1.3 days. Cost: 128 x $2.50 x 24 x 1.3 = ~$9,984.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 22)

# Item 24d (LO 24)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-163',
  content: 'Your research lab has a fixed compute budget of 10^23 FLOPs. The PI wants to train a 50B-parameter model. Using the Chinchilla scaling law, determine whether this is compute-optimal and propose an alternative if not. The model will be served to 10,000 daily users -- does this change your recommendation?',
  answer: 'Chinchilla-optimal: ~29B params on ~578B tokens. The 50B model is over-parameterised for this budget. However, for 10K daily users, inference cost dominates. Per Sardana et al. / Llama precedent, a smaller model (e.g., 13B) trained with extra data may be better: cheaper inference, wider deployability.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 24)

# Item 25c (LO 25)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 161-162',
  content: 'Your VP asks: "If we double our compute budget from 10^23 to 2x10^23 FLOPs, how much will the model improve?" Set realistic expectations and state the assumptions that must hold.',
  answer: 'Improvement is measurable but modest (logarithmic relationship). Doubling compute does not halve loss. Assumptions: dense model, predominantly human-generated data. MoE or synthetic data may not follow the same curve.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 25)

# Item 26b (LO 26)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 162-163',
  content: 'Your team is building an open-source model for the developer community. You have enough compute for a Chinchilla-optimal 30B model, but the head of product argues for 7B trained with extra data. Using the Llama precedent and Sardana et al., evaluate her argument.',
  answer: 'Llama chose smaller-than-optimal because smaller = cheaper inference = wider adoption. Sardana et al. modified Chinchilla to account for inference demand. For open-source targeting developers, a 7B model running on a consumer GPU has more impact than a 30B requiring multi-GPU. The product lead is correct.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 26)

# Item 26c (LO 26) -- REVISED per final blueprint: practitioner-format Slack message
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 162-163',
  content: 'Your CTO pushes back on your team\'s proposal to ship a 7B model: "Our competitors are releasing 30B models. How do we justify shipping something four times smaller?" Write the three-bullet Slack response you would send, backed by specific evidence from the chapter.',
  answer: '1. "Smaller model = massively cheaper inference. Sardana et al. (2023) showed inference cost dominates model lifecycle cost. At our scale, the 7B model costs ~4x less per query." 2. "The 7B model, trained on extra data beyond Chinchilla-optimal, actually outperforms a Chinchilla-optimal 30B -- Meta demonstrated this with Llama." 3. "Adoption matters more than benchmark margin. Open-source community engagement drops sharply above ~13B parameters. The 7B sweet spot maximises both performance and adoption."',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 26)

# Item 27c (LO 27)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 163-165',
  content: 'Your team ran hyperparameter sweeps on a 125M proxy model and plans to apply results directly to a 7B production run ($500K). What risk does the emergent abilities finding pose, and what safeguard would you add?',
  answer: 'The Microsoft/OpenAI paper supports hyperparameter transfer (40M to 6.7B). But emergent abilities mean some behaviours only appear at scale. Safeguard: budget for intermediate checkpoints (e.g., 1B) to validate trends before committing the full $500K.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 27)

# Item 28d (LO 28)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 159-160',
  content: 'A safety review board asks: "Does scaling always help?" Using the Inverse Scaling Prize findings and the Anthropic (Perez et al., 2022) result, provide an evidence-based answer that shapes model evaluation strategy.',
  answer: 'No. ISP found larger models sometimes worse on memorisation and strong-prior tasks. Anthropic found more alignment training can lead to expressing specific political/religious views. Evaluation strategy: test for inverse scaling in your domain, especially on memorisation tasks.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 28)

# Item 29c (LO 29)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 165-167',
  content: 'Your company\'s legal team is negotiating a data licensing deal with a major news publisher for $2M/year. The ML team thinks this is overpriced. Using Figure 2-9 trends and the Longpre et al. findings, evaluate whether the deal has strategic value.',
  answer: 'Villalobos et al.: data demand outpaces supply. Longpre et al.: 28% of C4 fully restricted, 45% restricted by ToS. Proprietary data is a moat (OpenAI/Axel Springer, AP deals). $2M/year is likely underpriced relative to strategic value.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 29)

# Item 30c (LO 30)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 167-168',
  content: 'Your company plans 10x GPU cluster expansion over 3 years. The facilities manager says power is the constraint. Using the chapter\'s electricity data, evaluate feasibility. Also address the risk of training on web-scraped data in 2026.',
  answer: '1-2% now, 4-20% by 2030, ~50x ceiling. 10x is within ceiling but requires power contracts. AI-generated data contamination (Grok using ChatGPT policy language) means web-scraped data quality is declining.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 30)

# Item 31c (LO 31)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 169-171',
  content: 'Your startup has a $1M compute budget and a base model that is capable but gives rude, unhelpful responses. A board member asks "should we retrain from scratch with better data?" Using the InstructGPT compute allocation data, argue that post-training is the right investment.',
  answer: 'Post-training = ~2% of compute = ~$20K. The capabilities are latent; SFT and preference finetuning unlock them. Redirect $980K savings to data curation for SFT and preference labelling.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 31)

# Item 32d (LO 32)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 171-172',
  content: 'A contractor delivers a "finetuned model" that is rude and unhelpful. You discover they only did SFT on domain data but skipped preference finetuning. Using the three-phase pipeline, explain what they missed and why the model behaves this way.',
  answer: 'Pipeline: pre-training -> SFT -> preference finetuning. SFT teaches instruction-following (behaviour cloning) but not which responses are preferred. Without preference finetuning, the model follows instructions but may do so rudely. The contractor needs to add comparison data and preference finetuning.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 32)

# Item 33c (LO 33)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 173-174',
  content: 'A cost-conscious team lead says: "GPT-4-base is already smart. Why spend $130K on SFT data? Let\'s just use detailed system prompts." Using the pizza example, explain why prompting a base model is insufficient.',
  answer: 'Base models are optimised for text completion, not instruction following. The pizza example shows three possible responses; only giving instructions is correct. System prompts cannot reliably override the completion objective. SFT teaches the model that questions should be answered, not continued.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 33)

# Item 34d (LO 34)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 174-177',
  content: 'A vendor offers two SFT data options: (a) 50,000 pairs from gig workers at $1/pair ($50K), or (b) 13,000 pairs from graduate-degree workers at $10/pair ($130K). Your PM says "50K > 13K." Using InstructGPT data, advise the PM.',
  answer: 'InstructGPT used 13,000 high-quality pairs (90% college, >1/3 master\'s, $10/pair). Quality > quantity for SFT. Option (b) matches the InstructGPT bar. Option (a) risks poor demonstrations that behaviour cloning amplifies.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 34)

# Item 35c (LO 35)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 177-178',
  content: 'Your non-profit wants to build an open-source instruction-following model for education. Budget is near zero. Evaluate the volunteer-sourced (LAION-style) approach: benefits, risks, and mitigations.',
  answer: 'Benefits: scale at zero cost (13,500 volunteers, 161K messages, 35 languages). Risks: 90% male demographic bias creates model that responds in ways preferred by male English speakers. Mitigation: actively recruit diverse volunteers, implement quality control.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 35)

# Item 36b (LO 36)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 179-182',
  content: 'A PM suggests using a 1-10 scale for each model response rather than A/B comparisons, arguing "numbers give more information." Using evidence from the chapter, explain why pairwise comparisons produce higher-quality preference data.',
  answer: 'Pointwise scoring unreliable (5 vs 7 example). No shared anchor for what "7" means. Comparisons more consistent: ~73% agreement. Also cheaper ($3.50 vs $25). PM gets less info per label but more reliable info and more labels per dollar.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 36)

# Item 38c (LO 38)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 184-185',
  content: 'Write the RLHF reward model loss function, identify all terms, and explain the objective in plain language. What does minimising this loss function achieve?',
  answer: '-E[log(sigma(r_theta(x, y_w) - r_theta(x, y_l)))]. r_theta = reward model, x = prompt, y_w = winning response, y_l = losing response, sigma = sigmoid. Objective: find theta such that the reward model assigns higher scores to human-preferred responses.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 38)

# Item 39c (LO 39)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 185-187',
  content: 'Your mid-size SaaS team is post-training a 7B model. The ML lead proposes RLHF with PPO. The senior engineer argues for DPO. Budget is limited and the team has never trained a reward model. Recommend an approach and justify.',
  answer: 'DPO: no reward model, less complexity, lower execution risk for inexperienced team. Fallback: reward model + best-of-N (Stitch Fix/Grab pattern) -- simpler than full RLHF. Full RLHF is highest risk given team experience.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 39)

# Item 41e (LO 41)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 189-191',
  content: 'Your model occasionally outputs a wrong classification with high confidence. You pull logits [2.1, 1.9, -5.0]. The model chose class 0. Compute softmax probabilities and assess whether the model is genuinely confident or classes 0 and 1 are nearly tied.',
  answer: 'P(0) = 0.55, P(1) = 0.45. Nearly tied. Model is not confident despite choosing class 0. Recommend: add a low-confidence threshold; route to human review when gap < 0.2.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 41)

# Item 42d (LO 42)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 191-195',
  content: 'A medical symptom checker was deployed with T=0.9 (copied from a marketing copy generator). Users report wildly different treatment suggestions for identical symptoms. Explain what T=0.9 does and recommend the correct setting.',
  answer: 'T=0.9 flattens the distribution, boosting less likely (potentially dangerous) medical advice. Recommended: T=0 or T=0.1 for medical applications. Also use top-p=0.5 or lower. This is a patient safety issue.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 42)

# Item 43c (LO 43)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 195-196',
  content: 'You are building a perplexity-based quality filter. Your implementation multiplies raw probabilities and keeps getting zero for long sequences. Explain why and how logprobs solve this.',
  answer: 'Vocabulary ~100K tokens means probabilities can be ~10^-5 or smaller. Multiplying 100+ produces underflow (rounds to zero). Logprobs: add log(P) instead of multiplying P. Stays numerically stable.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 43)

# Item 45c (LO 45)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 197-199',
  content: 'A creative writing assistant uses top-k=50. Users complain it is sometimes too creative and sometimes too constrained. Explain why top-p would fix this and recommend a setting.',
  answer: 'Top-k=50 always considers 50 tokens regardless of probability distribution. When top 3 tokens hold 99% probability, 47 garbage tokens are included. When probability is spread across 200, good options are cut. Top-p adapts dynamically. Recommend p=0.95 for creative writing.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 45)

# Item 47d (LO 47)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-202',
  content: 'You implement best-of-N reranking. Your first version picks the highest total logprob. "Yes." always wins over detailed responses. Explain why and fix it.',
  answer: 'Each token adds a negative logprob. Longer sequences accumulate more negatives. "Yes." has fewer tokens = higher total. Fix: divide by length (average logprob). OpenAI API uses this for best-of-N.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 47)

# Item 48b (LO 48)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 202-203',
  content: 'What does the Cobbe et al. finding (100M + verifier matches 3B) imply about the relationship between model size and performance? Cite the DeepMind (Snell et al., 2024) finding about test-time compute.',
  answer: 'Model size is not the only path to performance. Test-time compute (verifiers, multiple samples) can substitute for parameter scaling. Snell et al. argue scaling test-time compute can be more efficient than scaling parameters.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 48)

# Item 48c (LO 48)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 202-203',
  content: 'Your team debates upgrading from 7B to 70B for a math tutoring app (15% better on evals, 10x cost). You have a trained reward model. Propose an alternative using test-time compute.',
  answer: 'Generate 8-16 candidates with 7B, use reward model to select best. 8 candidates at 7B cost < 1 call at 70B (10x). Quality improvement from selection may exceed 15% gap. Test before upgrading.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 48)

# Item 49c (LO 49)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 203-204',
  content: 'Your team uses best-of-N with N=1000 for code generation. Quality degraded vs N=100. Using OpenAI and Brown et al. findings, explain why and recommend optimal N.',
  answer: 'OpenAI: performance peaks at ~400 then decreases (adversarial outputs fool verifier). At N=1000, past the peak. Brown et al. ("Monkey Business"): log-linear improvement to 10,000 with better verifier. Fix: reduce to 100-400 or invest in stronger verifier.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 49)

# Item 50c (LO 50)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-206',
  content: 'You are building a QA system with 16 candidates. You have logprobs, a domain reward model, and verifiable answers. Which selection method should you use and why? Explain why logprob scoring is weakest for factual QA.',
  answer: 'Self-consistency best for factual QA (Google used 32 for Gemini MMLU). Reward model second-best. Logprob weakest: it measures fluency, not correctness -- a fluent wrong answer scores higher than a less fluent correct one.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 50)

# Item 51b (LO 51)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 206-208',
  content: 'Your team builds: (1) a NL-to-SQL converter, and (2) a chatbot returning JSON for a React frontend. A junior engineer wants to use the same approach for both. Explain why these are different scenarios requiring different solutions.',
  answer: '(1) is inherently structured: the output IS SQL. Needs domain finetuning on text-to-SQL pairs. (2) is format wrapping: content is unstructured, only container is structured. Constrained JSON decoding is perfect for (2) but insufficient for (1).',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 51)

# Item 52d (LO 52)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 209-213',
  content: 'Your pipeline uses GPT-4 with prompting for contract entity extraction as JSON. Success rate: 91%. The 9% failure causes pipeline crashes and 5 hr/week manual fixes. Walk through a migration path from 91% to 99.99%+.',
  answer: 'Current: prompting at 91%. Step 1: post-processing (defensive JSON parser, fixes missing brackets). LinkedIn precedent: 90% -> 99.99%. Step 2: constrained sampling (outlines/instructor) for guaranteed valid JSON. Step 3: finetuning if entity extraction itself is wrong.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 52)

# Item 53b (LO 53)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 211',
  content: 'Your pipeline has 8% JSON malformation. A colleague suggests switching to YAML. Using the LinkedIn precedent, evaluate whether this would help and what else is needed.',
  answer: 'LinkedIn: YAML less verbose, fewer tokens, combined with defensive parser got 90% -> 99.99%. Switching to YAML may reduce malformation (fewer structural tokens to get wrong). But the key win is the defensive parser, not just format. Recommend both: YAML + defensive parser.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 53)

# Item 54c (LO 54)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 211-213',
  content: 'Your agentic pipeline requires JSON function calls: {"function": str, "args": dict}. Even with prompting and post-processing, 0.5% fail and crash the agent. Zero crash tolerance. Which framework would you use for constrained sampling, and what is the main trade-off?',
  answer: 'Use outlines (Python) or instructor (OpenAI API) to define JSON schema grammar. At each step, logits filtered to grammar-valid tokens. Guarantees 100% valid output. Trade-off: adds latency + requires grammar per schema. llama.cpp has GBNF support for local models.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 54)

# Item 55c (LO 55)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 213-214',
  content: 'Your content moderation uses GPT-4 prompting to classify into 12 categories at $50K/month. It sometimes outputs invalid categories. Design a classifier head solution.',
  answer: 'Take Llama 3-8B, append classification head with softmax over exactly 12 categories. Invalid categories impossible. Start with head-only finetuning (faster, cheaper, less data). Upgrade to end-to-end if accuracy insufficient. Serving cost: fraction of $50K/month.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 55)

# Item 58c (LO 58)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 219-220',
  content: 'Walk through the "Chip Huyen is an architect" self-delusion example step by step. Explain why the error cannot self-correct once it begins.',
  answer: 'Step 1: Model generates "Chip Huyen is an architect" (incorrect). Step 2: Subsequent tokens are conditioned on "architect" as fact. Step 3: Model generates consistent details (architecture projects, building descriptions). Step 4: Cannot self-correct because it cannot distinguish its generated tokens from user-provided context.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 58)

# Item 59d (LO 59)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 221-222',
  content: 'Explain both Figure 2-24 (shampoo/milk) and Figure 2-25 (9677 / 13) as instances of self-delusion. What common mechanism connects these very different error types?',
  answer: 'Both: initial error -> subsequent tokens conditioned on error -> cascade. Fig 2-24: vision misidentification -> ingredient list includes milk. Fig 2-25: math error -> subsequent questions answered incorrectly despite model capability. Common mechanism: model cannot distinguish generated errors from given facts.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 59)

# Item 60b (LO 60)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 222',
  content: 'Explain the mechanism of DeepMind\'s RL-based mitigation for self-delusion. How does teaching the model to differentiate "observations" from "actions" address the self-delusion problem?',
  answer: 'Observations = user-provided prompts (reliable data). Actions = model-generated tokens (potentially unreliable). RL trains the model to weight observations more heavily than its own generated content. This breaks the self-delusion loop.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 60)

# Item 61c (LO 61) -- REVISED per final blueprint: scaffolding leakage removed
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 223-224',
  content: 'You finetuned a model on expert medical QA data. Before finetuning, the model would hedge with "I\'m not sure" on conditions it had never seen. After finetuning, it now confidently answers questions about rare conditions it has never seen, sometimes fabricating dangerous information. Explain why finetuning made this worse, identifying which hallucination hypothesis from the chapter explains this behaviour, and propose two mitigations.',
  answer: 'The knowledge mismatch hypothesis (Leo Gao; Schulman) explains this. Expert labellers wrote confident answers using medical knowledge the model lacks. SFT taught the model to mimic the confidence pattern without having the underlying knowledge. Mitigations: (1) Verification -- require the model to retrieve and cite sources. (2) Reward function that punishes fabrication more heavily than hedging.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 61)

# Item 62c (LO 62)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 224-225',
  content: 'After RLHF, your model\'s user satisfaction jumped 20% but hallucination increased 15%. The head of product says "users like it more, so the hallucination is fine." Using the InstructGPT finding, explain why this reasoning is dangerous.',
  answer: 'Ouyang et al.: RLHF improved preference but worsened hallucination vs SFT alone. RLHF rewards confident, fluent, helpful-sounding responses -- exactly the properties that make hallucinations more dangerous. A user-preferred hallucination is worse than a user-disliked truthful response.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 62)

# Item 63c (LO 63)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 225-226',
  content: 'Your team is writing the system prompt for a financial advisory chatbot. Propose two prompting-based mitigations grounded in the hallucination hypotheses and explain why each works.',
  answer: '(1) "Answer as truthfully as possible. If unsure, say so." Addresses knowledge mismatch by giving model permission to express uncertainty. (2) "Be concise." Addresses self-delusion by reducing generated tokens, limiting opportunities for conditioning on errors. Both are free to implement.',
  points: 5,
  answer_size: 'medium',
  question_type: 'written',
  options: []
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 63)
