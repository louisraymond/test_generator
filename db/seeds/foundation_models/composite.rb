# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models composite...'

# Item 4d (LO 4)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 129-130',
  content: "(a) Name the three reasons why translating all queries to English is not a viable solution for multilingual AI deployment. (2 pts)\n(b) For each reason, provide a specific example from the chapter. (3 pts)\n(c) Construct the strongest counter-argument someone might make for a translate-to-English approach, then explain why it fails. (3 pts)",
  answer: "(a) Requires existing capability, information loss, unexpected behaviour.\n(b) Requires capability: need a good enough model in the source language. Information loss: Vietnamese pronouns collapse to \"I\" and \"you\". Unexpected behaviour: ChatGPT-3.5 generated misinformation in Chinese 7/7 times.\n(c) Counter-argument: \"English models are the best, so translate everything to use the best model.\" Fails because translation itself requires capability, loses nuance, and models behave differently across languages.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'Name the three reasons why translating all queries to English is not a viable solution for multilingual AI deployment.',
        'answer'  => 'Requires existing capability, information loss, unexpected behaviour.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'For each reason, provide a specific example from the chapter.',
        'answer'  => 'Requires capability: need a good enough model in the source language. Information loss: Vietnamese pronouns collapse to "I" and "you". Unexpected behaviour: ChatGPT-3.5 Chinese 7/7 misinformation.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Construct the strongest counter-argument for a translate-to-English approach, then explain why it fails.',
        'answer'  => 'Counter: "English models are the best, so translate everything." Fails because translation requires capability, loses nuance, and models behave differently across languages.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 4)

# Item 26c (LO 26)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 162-163',
  content: "(a) State the claim: \"Meta was correct to choose a sub-Chinchilla model size for Llama.\" (1 pt)\n(b) Provide two pieces of evidence from the chapter supporting this claim. (3 pts)\n(c) Construct the strongest counter-argument and explain why the evidence still favours the original claim. (4 pts)",
  answer: "(a) Claim: Meta was correct to choose sub-Chinchilla model size for Llama.\n(b) Smaller = cheaper inference; wider adoption. Sardana et al. showed inference cost dominates lifecycle cost.\n(c) Counter: sub-Chinchilla means under-trained, losing benchmark performance. Rebuttal: benchmark loss is modest; cost savings compound over millions of inference calls.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'State the claim: "Meta was correct to choose a sub-Chinchilla model size for Llama."',
        'answer'  => 'Claim stated.',
        'points'  => 1
      },
      {
        'type'    => 'written',
        'content' => 'Provide two pieces of evidence from the chapter supporting this claim.',
        'answer'  => 'Smaller = cheaper inference and wider adoption. Sardana et al. showed inference cost dominates lifecycle cost.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Construct the strongest counter-argument and explain why the evidence still favours the original claim.',
        'answer'  => 'Counter: sub-Chinchilla means under-trained, losing benchmark performance. Rebuttal: benchmark loss is modest; cost savings compound over millions of inference calls.',
        'points'  => 4
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 26)

# Item 35d (LO 35)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 177-178',
  content: "(a) Name the three SFT data approaches discussed in the chapter. (2 pts)\n(b) For each, state the primary cost/quality tradeoff. (3 pts)\n(c) For a medical chatbot requiring high accuracy, recommend one approach and justify. (3 pts)",
  answer: "(a) OpenAI paid labellers, LAION volunteers, DeepMind heuristic filter.\n(b) OpenAI: expensive but highest quality. LAION: free but biased (90% male). DeepMind: automated but noisy.\n(c) OpenAI-style with domain expert labellers; medical accuracy requires expert knowledge and controlled quality.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'Name the three SFT data approaches discussed in the chapter.',
        'answer'  => 'OpenAI paid labellers, LAION volunteers, DeepMind heuristic filter.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'For each approach, state the primary cost/quality tradeoff.',
        'answer'  => 'OpenAI: expensive but highest quality. LAION: free but biased. DeepMind: automated but noisy.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'For a medical chatbot requiring high accuracy, recommend one approach and justify.',
        'answer'  => 'OpenAI-style with domain expert labellers; medical accuracy requires expert knowledge.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 35)

# Item 36c (LO 36)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 179-184',
  content: "(a) State the claim: \"Comparison data is superior to pointwise scoring for preference finetuning.\" (1 pt)\n(b) Provide the 5-vs-7 scoring evidence. (2 pts)\n(c) Provide the cost evidence ($3.50 vs $25). (2 pts)\n(d) Address the counter-argument: \"A number gives more information than a binary comparison.\" (3 pts)",
  answer: "(a) Claim: Comparison data is superior to pointwise scoring.\n(b) One labeller gives 5, another gives 7 for the same sample -- no shared anchor, making scores unreliable.\n(c) $3.50/comparison vs $25/written response, approximately 7x cheaper.\n(d) True per label but more noise per label; comparison data is more reliable per dollar; ranking A>B>C generates 3 pairs from one session.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'State the claim: "Comparison data is superior to pointwise scoring for preference finetuning."',
        'answer'  => 'Claim stated.',
        'points'  => 1
      },
      {
        'type'    => 'written',
        'content' => 'Provide the 5-vs-7 scoring evidence showing why pointwise scoring is unreliable.',
        'answer'  => 'One labeller gives 5, another gives 7 for the same sample -- no shared anchor.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Provide the cost evidence comparing comparison data to written responses.',
        'answer'  => '$3.50 per comparison vs $25 per written response (approximately 7x cheaper).',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Address the counter-argument: "A number gives more information than a binary comparison."',
        'answer'  => 'True per label, but comparison data is more reliable per dollar; ranking A>B>C generates 3 pairs from one session.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 36)

# Item 50d (LO 50)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 201-206',
  content: "(a) Name the three best-of-N selection methods. (2 pts)\n(b) For each, state when it is most appropriate. (3 pts)\n(c) Explain why logprob scoring is the weakest method for factual QA. (3 pts)",
  answer: "(a) Logprob, reward model, self-consistency.\n(b) Logprob: when no reward model available. Reward model: general quality assessment. Self-consistency: factual questions with verifiable answers.\n(c) Logprob measures fluency, not correctness. A wrong but fluent answer will score higher than a correct but clunky one.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'Name the three best-of-N selection methods.',
        'answer'  => 'Logprob, reward model, self-consistency.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'For each method, state when it is most appropriate.',
        'answer'  => 'Logprob: when no reward model available. Reward model: general quality. Self-consistency: factual with verifiable answers.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Explain why logprob scoring is the weakest method for factual QA.',
        'answer'  => 'Logprob measures fluency, not correctness. Wrong fluent answer scores higher than right clunky answer.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 50)

# Item 56c (LO 56)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 214-218',
  content: "Your essay grading system scores the same essay 3/5 then 5/5 (the chapter's example). Parents complain about unfair grading.\n(a) Diagnose the root cause. (2 pts)\n(b) Implement a fix that guarantees consistency. (3 pts)\n(c) Explain the hardware caveat that limits even \"deterministic\" settings. (3 pts)",
  answer: "(a) Probabilistic sampling -- non-deterministic generation produces different outputs for the same input.\n(b) Set T=0, fix the random seed, fix top-p/top-k, use response caching.\n(c) Different GPUs or batch compositions can produce different floating-point results even with identical settings due to hardware-level non-determinism.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'Diagnose the root cause of inconsistent essay scores.',
        'answer'  => 'Probabilistic sampling: non-deterministic generation produces different outputs for the same input.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Implement a fix that guarantees consistency.',
        'answer'  => 'Set T=0, fix random seed, fix top-p/top-k, use response caching.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Explain the hardware caveat that limits even "deterministic" settings.',
        'answer'  => 'Different GPUs or batch compositions can produce different floating-point results even with identical settings.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 56)

# Item 58d (LO 58)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 219-220',
  content: "Your RAG system retrieves correct documents (\"refund within 30 days\") but the model outputs \"refund within 60 days.\"\n(a) State the self-delusion hypothesis. (2 pts)\n(b) Trace how the model might override correct context. (3 pts)\n(c) Propose a mitigation for RAG-specific self-delusion. (3 pts)",
  answer: "(a) The model cannot differentiate between data it is given and data it generates.\n(b) Training data patterns prime \"60 days\"; once generated, subsequent tokens condition on \"60\" as fact, overriding the retrieved \"30 days\" context.\n(c) Have the model quote directly from retrieved text; reduce paraphrasing to limit generated-token conditioning.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'State the self-delusion hypothesis.',
        'answer'  => 'The model cannot differentiate between data it is given and data it generates.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Trace how the model might override the correct retrieved context ("30 days") and output "60 days".',
        'answer'  => 'Training data patterns prime "60 days"; once generated, subsequent tokens condition on "60" as fact.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Propose a mitigation for RAG-specific self-delusion.',
        'answer'  => 'Have model quote directly from retrieved text; reduce paraphrasing to limit generated-token conditioning.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 58)

# Item 60c (LO 60)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'p. 222',
  content: "(a) Name DeepMind's first self-delusion mitigation technique. (2 pts)\n(b) Explain its mechanism. (2 pts)\n(c) Name the second technique. (2 pts)\n(d) Explain its mechanism. (2 pts)",
  answer: "(a) RL for observation/action differentiation.\n(b) Trains the model to distinguish user input (observations) from its own generated output (actions), reducing the confusion that drives self-delusion.\n(c) Supervised learning with factual and counterfactual signals.\n(d) Training data includes both correct and incorrect examples with labels, teaching the model to recognise when it is generating fiction vs fact.",
  points: 8,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => "Name DeepMind's first self-delusion mitigation technique.",
        'answer'  => 'RL for observation/action differentiation.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Explain the mechanism of the first technique.',
        'answer'  => 'Trains model to distinguish user input (observations) from its own generated output (actions).',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => "Name DeepMind's second self-delusion mitigation technique.",
        'answer'  => 'Supervised learning with factual and counterfactual signals.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Explain the mechanism of the second technique.',
        'answer'  => 'Training data includes both correct and incorrect examples with labels, teaching the model to recognise when it is generating fiction.',
        'points'  => 2
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 60)

# Item 61d (LO 61)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 223-224',
  content: "(a) State the knowledge mismatch hypothesis. (2 pts)\n(b) Explain Schulman's claim that LLMs know whether they know something. (2 pts)\n(c) Describe the verification solution. (3 pts)\n(d) Describe the reward function solution. (3 pts)",
  answer: "(a) SFT teaches the model to mimic labeller responses that draw on knowledge the model does not possess, effectively training it to hallucinate.\n(b) LLMs have metacognitive-like behaviour; they can indicate uncertainty if trained to do so.\n(c) Ask the model to retrieve sources before stating claims; if no source is found, output \"I don't know.\"\n(d) In preference finetuning, penalise responses that fabricate claims not grounded in training data.",
  points: 10,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'State the knowledge mismatch hypothesis.',
        'answer'  => 'SFT teaches the model to mimic labeller responses drawing on knowledge the model lacks, training it to hallucinate.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => "Explain Schulman's claim that LLMs know whether they know something.",
        'answer'  => 'LLMs have metacognitive-like behaviour; they can indicate uncertainty if trained to do so.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Describe the verification solution to knowledge mismatch hallucination.',
        'answer'  => "Ask model to retrieve sources before stating claims; if no source, output \"I don't know.\"",
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Describe the reward function solution to knowledge mismatch hallucination.',
        'answer'  => 'In preference finetuning, penalise responses that fabricate claims not grounded in training data.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 61)

# Item 63d (LO 63)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 225-226',
  content: "(a) Classify the self-delusion hypothesis by its cause. (2 pts)\n(b) Classify the knowledge mismatch hypothesis by its cause. (2 pts)\n(c) Explain why these two hypotheses are complementary, not competing. (3 pts)\n(d) Propose two zero-cost prompting mitigations and link each to one hypothesis. (3 pts)",
  answer: "(a) Self-supervision: the model's own generation process creates hallucinations.\n(b) SFT/supervision: the training process teaches the model to hallucinate by mimicking labeller knowledge.\n(c) Self-delusion explains how the model's generation creates hallucinations; knowledge mismatch explains how training teaches it. They describe different mechanisms that can co-occur in the same model.\n(d) \"Answer truthfully\" -> knowledge mismatch. \"Be concise\" -> self-delusion (fewer generated tokens = less snowballing).",
  points: 10,
  question_type: 'composite',
  options: {
    'parts' => [
      {
        'type'    => 'written',
        'content' => 'Classify the self-delusion hypothesis by its cause.',
        'answer'  => 'Self-supervision: the model conditions on its own generated errors.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Classify the knowledge mismatch hypothesis by its cause.',
        'answer'  => 'SFT/supervision: training mimics labeller knowledge the model lacks.',
        'points'  => 2
      },
      {
        'type'    => 'written',
        'content' => 'Explain why these two hypotheses are complementary, not competing.',
        'answer'  => 'They describe different mechanisms (generation vs training) that can co-occur in the same model.',
        'points'  => 3
      },
      {
        'type'    => 'written',
        'content' => 'Propose two zero-cost prompting mitigations and link each to one hypothesis.',
        'answer'  => '"Answer truthfully" -> knowledge mismatch. "Be concise" -> self-delusion.',
        'points'  => 3
      }
    ]
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 63)
