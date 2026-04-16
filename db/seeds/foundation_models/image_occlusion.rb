# frozen_string_literal: true

topic = Topic.find_by!(name: 'AI Engineering - Foundation Models')
source = Source.find_by!(name: 'AI Engineering by Chip Huyen')

puts '  - Foundation Models image_occlusion...'

# Item 3b (LO 3)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 128-129',
  content: 'In Figure 2-2 (GPT-4 math performance by language, Yennie Jun\'s Project Euler experiment), the results for two languages have been hidden. Both scored zero correct out of six questions. Name these two languages.',
  answer: 'Burmese and Amharic. (Accept alternate spellings: Myanmar for Burmese.)',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-2-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 3)

# Item 6b (LO 6)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 132-134',
  content: 'In Figure 2-3, the largest domain category has been hidden. Based on the remaining visible data and your knowledge of C4\'s composition, identify the hidden domain category and its approximate share.',
  answer: 'Accept the largest domain category visible in the figure with a reasonable percentage estimate (within 10% of actual).',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-3-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 6)

# Item 25b (LO 25)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 161-162',
  content: 'In Figure 2-8, the relationship between compute budget and training loss has been partially hidden. Describe the shape of this relationship: does more compute always reduce loss? Is the relationship linear?',
  answer: 'More compute reduces loss, but the relationship is logarithmic (diminishing returns). Doubling compute does not halve the loss.',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-8-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 25)

# Item 29b (LO 29)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 165-167',
  content: 'In Figure 2-9, the projected intersection point where data demand exceeds supply has been hidden. What does this intersection imply for AI companies?',
  answer: 'Proprietary data becomes a competitive advantage. Companies will need exclusive data sources to maintain training quality as freely available data becomes scarcer.',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-9-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 29)

# Item 34b (LO 34)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 174-177',
  content: 'In Figure 2-12, one task category and its percentage have been hidden. Based on the visible distribution and your knowledge of InstructGPT, identify the hidden category.',
  answer: 'Accept the largest or most notable category from the figure with a reasonable percentage estimate.',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-12-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 34)

# Item 42c (LO 42)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 191-195',
  content: 'In the worked example, the T=0.5 probability values have been hidden. Given logits [1, 2] and T=0.5, what are the resulting probabilities?',
  answer: '[0.12, 0.88] (accept within 0.02 tolerance for each value).',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-16-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 42)

# Item 49b (LO 49)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 203-204',
  content: 'The approximate number of outputs where performance peaks has been hidden in Figure 2-19. What is this number, and what causes the subsequent degradation?',
  answer: 'Approximately 400. The subsequent degradation is caused by adversarial outputs that fool the verifier.',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-19-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 49)

# Item 59b (LO 59)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 221-222',
  content: 'In Figure 2-24, the initial misidentification has been hidden. Given that the model later lists "milk" as an ingredient, what object was likely misidentified?',
  answer: 'A shampoo bottle (misidentified as milk).',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-24-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 59)

# Item 62b (LO 62)
q = Question.create!(
  topic: topic,
  source: source,
  source_reference: 'pp. 224-225',
  content: 'In Figure 2-26, the hallucination comparison metric has been hidden. Based on the chapter, did RLHF improve or worsen hallucination compared to SFT alone?',
  answer: 'RLHF worsened hallucination compared to SFT alone.',
  points: 2,
  question_type: 'image_occlusion',
  options: {
    'image' => 'fig2-26-000.png',
    'masks' => []
  }
)
q.learning_objectives << LearningObjective.find_by!(topic: topic, position: 62)
