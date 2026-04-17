# frozen_string_literal: true
#
# Maths exemplar — MULTIPLE CHOICE with inline math inside each choice.

topic  = Topic.find_by!(name: 'Maths - Exemplars (v1 sampler)')
ml     = topic.topic_modules.find_by!(name: 'Machine Learning')

claude = Source.find_by(name: 'Claude (claude-opus-4-7, 2026)')

puts '  - Maths multiple_choice exemplars...'

# 12. ML - Softmax / cross-entropy
Question.create!(
  topic: topic, topic_module: ml, source: claude,
  source_reference: 'Original — softmax + cross-entropy conceptual check',
  question_type: 'multiple_choice',
  answer_size: 'short',
  points: 2,
  content: <<~'CON'.strip,
    Which of the following statements about the softmax function $\sigma(\mathbf{z})_i = \dfrac{e^{z_i}}{\sum_j e^{z_j}}$ and cross-entropy loss $\mathcal{L} = -\sum_i y_i \log \hat{y}_i$ (with one-hot target $\mathbf{y}$ and softmax output $\hat{\mathbf{y}}$) is correct?
  CON
  answer: 'The gradient of cross-entropy loss with respect to the pre-softmax logits is $\hat{\mathbf{y}} - \mathbf{y}$.',
  options: [
    {
      'text' => 'Softmax outputs sum to $1$ only when all logits $z_i$ are non-negative.',
      'correct' => false
    },
    {
      'text' => 'The gradient of the cross-entropy loss with respect to the pre-softmax logits is $\hat{\mathbf{y}} - \mathbf{y}$.',
      'correct' => true
    },
    {
      'text' => 'Adding the same constant $c$ to every logit $z_i$ changes the resulting softmax probabilities.',
      'correct' => false
    },
    {
      'text' => 'Cross-entropy loss is minimised when $\hat{y}_i = \tfrac{1}{K}$ for $K$ classes, regardless of the target.',
      'correct' => false
    }
  ]
)

puts "  ✓ Created #{Question.where(topic: topic, question_type: 'multiple_choice').count} maths multiple_choice exemplars"
