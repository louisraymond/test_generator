# frozen_string_literal: true
#
# Maths exemplar — CALCULATION questions (numeric-with-unit final answer).

topic      = Topic.find_by!(name: 'Maths - Exemplars (v1 sampler)')
lin_alg    = topic.topic_modules.find_by!(name: 'Linear Algebra')
stats      = topic.topic_modules.find_by!(name: 'Probability & Statistics')
ml         = topic.topic_modules.find_by!(name: 'Machine Learning')

axler     = Source.find_by(name: 'Linear Algebra Done Right — Axler (4e)')
rohatgi   = Source.find_by(name: 'An Introduction to Probability and Statistics — Rohatgi & Saleh')
claude    = Source.find_by(name: 'Claude (claude-opus-4-7, 2026)')

puts '  - Maths calculation exemplars...'

# 6. Linear Algebra - Eigenvalues
Question.create!(
  topic: topic, topic_module: lin_alg, source: axler,
  source_reference: 'Axler Ch. 5 — eigenvalues of a 2x2 symmetric matrix',
  question_type: 'calculation',
  answer_size: 'short',
  points: 3,
  answer_label: 'eigenvalues',
  unit: '',
  content: <<~'CON'.strip,
    Find the eigenvalues of $A = \begin{pmatrix} 2 & 1 \\ 1 & 2 \end{pmatrix}$.
  CON
  answer: <<~'ANS'
    Characteristic polynomial: $\det(A - \lambda I) = (2-\lambda)^2 - 1$. **M1**

    Expand: $\lambda^2 - 4\lambda + 3 = (\lambda - 3)(\lambda - 1) = 0$. **A1**

    Eigenvalues: $\lambda_1 = 3$, $\lambda_2 = 1$. **A1**
  ANS
)

# 9. Stats - Bayesian (disease test)
Question.create!(
  topic: topic, topic_module: stats, source: rohatgi,
  source_reference: 'Rohatgi & Saleh — classic diagnostic-test exercise',
  question_type: 'calculation',
  answer_size: 'medium',
  points: 4,
  answer_label: '$P(D \mid +)$',
  unit: '%',
  content: <<~'CON'.strip,
    A disease has prevalence $P(D) = 0.01$ in the population. A diagnostic test has sensitivity $P(+\mid D) = 0.99$ and specificity $P(-\mid D^c) = 0.95$. Given a person tests positive, compute $P(D \mid +)$. Give your answer as a percentage to one decimal place.
  CON
  answer: <<~'ANS'
    By Bayes' theorem:

    $$P(D \mid +) = \dfrac{P(+ \mid D)\,P(D)}{P(+)} = \dfrac{P(+ \mid D)\,P(D)}{P(+\mid D)P(D) + P(+\mid D^c)P(D^c)}.$$
    **M1**

    Numerator: $0.99 \times 0.01 = 0.0099$. **A1**

    Denominator: $0.99 \times 0.01 + 0.05 \times 0.99 = 0.0099 + 0.0495 = 0.0594$. **M1**

    $P(D \mid +) = \dfrac{0.0099}{0.0594} \approx 0.1667 = 16.7\%$. **A1**
  ANS
)

# 11. ML - Gradient descent step
Question.create!(
  topic: topic, topic_module: ml, source: claude,
  source_reference: 'Original — linear-regression gradient step',
  question_type: 'calculation',
  answer_size: 'medium',
  points: 5,
  answer_label: '$\mathbf{w}_1$',
  unit: '',
  content: <<~'CON'.strip,
    Consider the least-squares loss $L(\mathbf{w}) = \tfrac{1}{2}\lVert \mathbf{Xw} - \mathbf{y} \rVert^2$ with

    $$\mathbf{X} = \begin{pmatrix} 1 & 2 \\ 1 & -1 \end{pmatrix}, \quad \mathbf{y} = \begin{pmatrix} 3 \\ 0 \end{pmatrix}, \quad \mathbf{w}_0 = \begin{pmatrix} 0 \\ 0 \end{pmatrix}.$$

    Compute $\nabla_{\mathbf{w}} L(\mathbf{w}_0)$ and the updated weight $\mathbf{w}_1 = \mathbf{w}_0 - \eta\,\nabla_{\mathbf{w}} L(\mathbf{w}_0)$ using learning rate $\eta = \tfrac{1}{10}$.
  CON
  answer: <<~'ANS'
    $\nabla_{\mathbf{w}} L(\mathbf{w}) = \mathbf{X}^{\top}(\mathbf{Xw} - \mathbf{y})$. **M1**

    At $\mathbf{w}_0$: $\mathbf{Xw}_0 - \mathbf{y} = -\mathbf{y} = \begin{pmatrix} -3 \\ 0 \end{pmatrix}$. **A1**

    $\nabla_{\mathbf{w}} L(\mathbf{w}_0) = \begin{pmatrix} 1 & 1 \\ 2 & -1 \end{pmatrix}\begin{pmatrix} -3 \\ 0 \end{pmatrix} = \begin{pmatrix} -3 \\ -6 \end{pmatrix}$. **A1**

    $$\mathbf{w}_1 = \begin{pmatrix} 0 \\ 0 \end{pmatrix} - \tfrac{1}{10}\begin{pmatrix} -3 \\ -6 \end{pmatrix} = \begin{pmatrix} 0.3 \\ 0.6 \end{pmatrix}.$$
    **M1 A1**
  ANS
)

puts "  ✓ Created #{Question.where(topic: topic, question_type: 'calculation').count} maths calculation exemplars"
