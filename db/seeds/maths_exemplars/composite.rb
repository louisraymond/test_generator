# frozen_string_literal: true
#
# Maths exemplar — COMPOSITE multi-part questions.
# Parts are an array under options['parts']; parent `points` equals the sum.

topic     = Topic.find_by!(name: 'Maths - Exemplars (v1 sampler)')
ibp       = topic.topic_modules.find_by!(name: 'Pure - Integration by parts')
numerical = topic.topic_modules.find_by!(name: 'Numerical Methods')

aqa1   = Source.find_by(name: 'AQA A-Level Mathematics Paper 1')
aqa2   = Source.find_by(name: 'AQA A-Level Mathematics Paper 2')

puts '  - Maths composite exemplars...'

# 3. Pure - Integration by parts (3 parts)
Question.create!(
  topic: topic, topic_module: ibp, source: aqa1,
  source_reference: 'AQA Paper 1 style — integration by parts sweep',
  question_type: 'composite',
  answer_size: 'long',
  points: 10,
  content: 'Integration by parts is the calculus analogue of the product rule. In this question you will derive it, then apply it to two standard integrals.',
  answer: <<~'ANS',
    a) $\dfrac{d}{dx}(uv) = u\dfrac{dv}{dx} + v\dfrac{du}{dx}$, and rearranging gives $\displaystyle\int u\,\mathrm{d}v = uv - \int v\,\mathrm{d}u$.

    b) $\displaystyle\int x e^x\,\mathrm{d}x = xe^x - e^x + C$.

    c) $\displaystyle\int \ln x\,\mathrm{d}x = x\ln x - x + C$.
  ANS
  options: {
    'parts' => [
      {
        'type' => 'written',
        'content' => 'a) By differentiating the product $uv$ with respect to $x$ and integrating both sides, derive the integration-by-parts formula $\displaystyle\int u\,\mathrm{d}v = uv - \int v\,\mathrm{d}u$.',
        'answer_size' => 'short',
        'points' => 2
      },
      {
        'type' => 'calculation',
        'content' => 'b) Use integration by parts to find $\displaystyle\int x e^x\,\mathrm{d}x$. Include the constant of integration.',
        'answer_size' => 'medium',
        'points' => 4,
        'answer_label' => 'integral',
        'unit' => ''
      },
      {
        'type' => 'calculation',
        'content' => 'c) Use integration by parts to find $\displaystyle\int \ln x\,\mathrm{d}x$ (hint: take $u = \ln x$, $\mathrm{d}v = \mathrm{d}x$). Include the constant of integration.',
        'answer_size' => 'medium',
        'points' => 4,
        'answer_label' => 'integral',
        'unit' => ''
      }
    ]
  }
)

# 14. Numerical methods - Newton-Raphson (2 parts, mixed types)
Question.create!(
  topic: topic, topic_module: numerical, source: aqa2,
  source_reference: 'AQA Paper 2 style — Newton-Raphson iteration',
  question_type: 'composite',
  answer_size: 'medium',
  points: 6,
  content: <<~'CON'.strip,
    The equation $f(x) = x^3 - 2x - 5 = 0$ has a root near $x_0 = 2$. This question walks through one Newton-Raphson iteration.
  CON
  answer: <<~'ANS',
    a) Newton-Raphson formula: $x_{n+1} = x_n - \dfrac{f(x_n)}{f'(x_n)}$.

    b) $f(2) = -1$, $f'(2) = 10$, so $x_1 = 2 - \dfrac{-1}{10} = 2.1$.
  ANS
  options: {
    'parts' => [
      {
        'type' => 'written',
        'content' => 'a) State the Newton-Raphson iterative formula for approximating a root of $f(x) = 0$ from an estimate $x_n$.',
        'answer_size' => 'short',
        'points' => 2
      },
      {
        'type' => 'calculation',
        'content' => 'b) Starting from $x_0 = 2$, apply one Newton-Raphson step to $f(x) = x^3 - 2x - 5$ to obtain $x_1$. Give your answer exactly.',
        'answer_size' => 'medium',
        'points' => 4,
        'answer_label' => '$x_1$',
        'unit' => ''
      }
    ]
  }
)

puts "  ✓ Created #{Question.where(topic: topic, question_type: 'composite').count} maths composite exemplars"
