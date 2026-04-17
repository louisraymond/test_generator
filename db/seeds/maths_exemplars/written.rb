# frozen_string_literal: true
#
# Maths exemplar — WRITTEN questions.
# These exercise inline/display LaTeX, aligned blocks with \tag, cases, pmatrix,
# epsilon-delta proofs, polar form, hypothesis tests, and figure-via-markdown.
# Mark schemes use **M1** / **A1** / **B1** bold callouts.

topic     = Topic.find_by!(name: 'Maths - Exemplars (v1 sampler)')
diff      = topic.topic_modules.find_by!(name: 'Pure - Differentiation')
integ     = topic.topic_modules.find_by!(name: 'Pure - Integration')
step_mod  = topic.topic_modules.find_by!(name: 'STEP - Proof')
lin_alg   = topic.topic_modules.find_by!(name: 'Linear Algebra')
analysis  = topic.topic_modules.find_by!(name: 'Real Analysis')
complex   = topic.topic_modules.find_by!(name: 'Complex Numbers')
stats     = topic.topic_modules.find_by!(name: 'Probability & Statistics')
geometry  = topic.topic_modules.find_by!(name: 'Geometry - Vectors')

aqa1   = Source.find_by(name: 'AQA A-Level Mathematics Paper 1')
step2  = Source.find_by(name: 'Cambridge STEP II')
axler  = Source.find_by(name: 'Linear Algebra Done Right — Axler (4e)')
rudin  = Source.find_by(name: 'Principles of Mathematical Analysis — Rudin (3e)')
claude = Source.find_by(name: 'Claude (claude-opus-4-7, 2026)')

puts '  - Maths written exemplars...'

# 1. Pure - Differentiation (inline math + M1/A1)
Question.create!(
  topic: topic, topic_module: diff, source: aqa1,
  source_reference: 'AQA Paper 1 style — 2019 Q3',
  question_type: 'written',
  answer_size: 'short',
  points: 3,
  content: 'Differentiate $y = \sin(3x^2 + 1)$ with respect to $x$, simplifying your answer fully.',
  answer: <<~'ANS'
    Apply the chain rule: let $u = 3x^2 + 1$, so $y = \sin u$.

    $\dfrac{du}{dx} = 6x$ and $\dfrac{dy}{du} = \cos u$. **M1**

    $\dfrac{dy}{dx} = \dfrac{dy}{du}\cdot\dfrac{du}{dx} = 6x\cos(3x^2 + 1)$. **A1**
  ANS
)

# 2. Pure - Integration (display + aligned + \tag)
Question.create!(
  topic: topic, topic_module: integ, source: aqa1,
  source_reference: 'AQA Paper 1 style — 2021 Q8',
  question_type: 'written',
  answer_size: 'medium',
  points: 5,
  content: 'Find the exact value of $\displaystyle\int_{0}^{\pi/2} x\cos x\,\mathrm{d}x$.',
  answer: <<~'ANS'
    Use integration by parts with $u = x$, $\mathrm{d}v = \cos x\,\mathrm{d}x$, so $\mathrm{d}u = \mathrm{d}x$ and $v = \sin x$. **M1**

    $$
    \begin{aligned}
    \int_{0}^{\pi/2} x\cos x\,\mathrm{d}x
      &= \Bigl[x\sin x\Bigr]_{0}^{\pi/2} - \int_{0}^{\pi/2}\sin x\,\mathrm{d}x \\
      &= \tfrac{\pi}{2}\cdot 1 - \Bigl[-\cos x\Bigr]_{0}^{\pi/2} \\
      &= \tfrac{\pi}{2} + (0 - 1) \\
      &= \tfrac{\pi}{2} - 1.
    \end{aligned}
    $$

    Evaluation of the boundary terms **A1**; substitution of limits **M1**; final exact form $\dfrac{\pi}{2} - 1$ **A1 A1**.
  ANS
)

# 4. STEP - Proof (cases, \forall, \Rightarrow)
Question.create!(
  topic: topic, topic_module: step_mod, source: step2,
  source_reference: 'STEP II style — split-by-parity induction',
  question_type: 'written',
  answer_size: 'long',
  points: 6,
  content: 'Prove that for every $n \in \mathbb{N}$, the expression $n^3 - n$ is divisible by $6$.',
  answer: <<~'ANS'
    Factor: $n^3 - n = n(n-1)(n+1)$, a product of three consecutive integers.

    $$n(n-1)(n+1) = \begin{cases}
      6k & \text{for some } k \in \mathbb{Z}, \text{ as shown below.}
    \end{cases}$$

    Among any three consecutive integers exactly one is divisible by $3$, so $3 \mid n(n-1)(n+1)$. **M1 A1**

    Among any two consecutive integers one is even, so $2 \mid n(n-1)(n+1)$. **M1 A1**

    Since $\gcd(2,3)=1$, we have $6 \mid n(n-1)(n+1)$, i.e. $n^3 - n \equiv 0 \pmod{6}$ for all $n \in \mathbb{N}$. $\Rightarrow$ **A1 A1**
  ANS
)

# 5. Linear Algebra - Matrices (pmatrix, \det)
Question.create!(
  topic: topic, topic_module: lin_alg, source: axler,
  source_reference: 'Axler Ch. 3 (Linear Maps) — cofactor style',
  question_type: 'written',
  answer_size: 'medium',
  points: 4,
  content: <<~'CON'.strip,
    Let $A = \begin{pmatrix} 1 & 2 & 3 \\ 0 & 1 & 4 \\ 5 & 6 & 0 \end{pmatrix}$. Compute $\det(A)$ by cofactor expansion along the first row.
  CON
  answer: <<~'ANS'
    Expand along row 1:

    $$\det(A) = 1\cdot\det\begin{pmatrix} 1 & 4 \\ 6 & 0 \end{pmatrix} - 2\cdot\det\begin{pmatrix} 0 & 4 \\ 5 & 0 \end{pmatrix} + 3\cdot\det\begin{pmatrix} 0 & 1 \\ 5 & 6 \end{pmatrix}.$$

    $= 1\cdot(0 - 24) - 2\cdot(0 - 20) + 3\cdot(0 - 5)$ **M1 A1**

    $= -24 + 40 - 15 = 1$. **A1 A1**
  ANS
)

# 7. Real Analysis - Limits (epsilon-delta)
Question.create!(
  topic: topic, topic_module: analysis, source: rudin,
  source_reference: 'Rudin Ch. 4 — continuity exercises',
  question_type: 'written',
  answer_size: 'medium',
  points: 5,
  content: 'Using the $\varepsilon$–$\delta$ definition of a limit, prove that $\displaystyle\lim_{x\to 2}(3x + 1) = 7$.',
  answer: <<~'ANS'
    Let $\varepsilon > 0$. We seek $\delta > 0$ such that $0 < |x - 2| < \delta \;\Rightarrow\; |(3x+1) - 7| < \varepsilon$. **M1**

    Compute $|(3x+1) - 7| = |3x - 6| = 3|x - 2|$. **A1**

    Choose $\delta = \dfrac{\varepsilon}{3}$. **M1**

    Then $0 < |x - 2| < \delta$ gives $|(3x+1) - 7| = 3|x-2| < 3\cdot\dfrac{\varepsilon}{3} = \varepsilon$. **A1 A1**
  ANS
)

# 8. Complex numbers (de Moivre, polar form)
Question.create!(
  topic: topic, topic_module: complex, source: aqa1,
  source_reference: 'AQA Further Pure style — de Moivre',
  question_type: 'written',
  answer_size: 'medium',
  points: 4,
  content: 'Express $(1 + i)^6$ in the form $a + b\,i$, where $a, b \in \mathbb{R}$, using de Moivre\'s theorem.',
  answer: <<~'ANS'
    Write $1 + i$ in polar form. $|1+i| = \sqrt{2}$, $\arg(1+i) = \tfrac{\pi}{4}$, so $1 + i = \sqrt{2}\,\operatorname{cis}\tfrac{\pi}{4}$. **M1 A1**

    By de Moivre: $(1+i)^6 = (\sqrt{2})^6\,\operatorname{cis}\tfrac{6\pi}{4} = 8\,\operatorname{cis}\tfrac{3\pi}{2}$. **M1 A1**

    Convert back: $\operatorname{Re}((1+i)^6) = 8\cos\tfrac{3\pi}{2} = 0$ and $\operatorname{Im}((1+i)^6) = 8\sin\tfrac{3\pi}{2} = -8$. **A1**

    $(1+i)^6 = 0 - 8i = -8i$.
  ANS
)

# 10. Stats - Hypothesis test
Question.create!(
  topic: topic, topic_module: stats, source: aqa1,
  source_reference: 'AQA Paper 3 style — z-test single mean',
  question_type: 'written',
  answer_size: 'long',
  points: 6,
  content: <<~'CON'.strip,
    A supplier claims the mean weight of their 500 g bags of coffee is $\mu = 500$. A customer weighs a random sample of $n = 25$ bags and finds a sample mean of $\bar{X} = 495$ g. Historic data gives population standard deviation $\sigma = 12$ g. Test at the $5\%$ significance level whether the true mean is less than the claim, stating clearly the null and alternative hypotheses and your conclusion.
  CON
  answer: <<~'ANS'
    **Hypotheses.** $H_0: \mu = 500$ vs. $H_1: \mu < 500$ (one-tailed, lower). **B1**

    **Test statistic.** Under $H_0$, $\bar{X} \sim N\!\left(500,\,\dfrac{\sigma^2}{n}\right) = N(500, 5.76)$, so
    $$z = \dfrac{\bar{X} - \mu_0}{\sigma/\sqrt{n}} = \dfrac{495 - 500}{12/\sqrt{25}} = \dfrac{-5}{2.4} \approx -2.083.$$
    **M1 A1**

    **Critical value.** For a one-tailed test at $5\%$, $z_{\text{crit}} = -1.645$. **B1**

    **Decision.** Since $-2.083 < -1.645$, the test statistic lies in the rejection region. **M1**

    **Conclusion.** Reject $H_0$ at the $5\%$ significance level. There is evidence that the true mean bag weight is less than 500 g. **A1**
  ANS
)

# 13. Geometry - Vectors (WITH FIGURE)
Question.create!(
  topic: topic, topic_module: geometry, source: aqa1,
  source_reference: 'AQA Paper 1 style — vectors and dot product',
  question_type: 'written',
  answer_size: 'medium',
  points: 4,
  content: <<~'CON',
    The diagram shows vectors $\vec{a} = \begin{pmatrix} 3 \\ 1 \end{pmatrix}$ and $\vec{b} = \begin{pmatrix} 4 \\ -2 \end{pmatrix}$ drawn from the origin $O$.

    ![Two vectors a and b from origin O with angle theta between them](/assets/maths/exemplars/fig-vectors-01.svg)

    Find the angle $\theta$ between $\vec{a}$ and $\vec{b}$, giving your answer in degrees to one decimal place.
  CON
  answer: <<~'ANS'
    Compute the dot product: $\vec{a}\cdot\vec{b} = 3\cdot 4 + 1\cdot(-2) = 10$. **M1 A1**

    Magnitudes: $|\vec{a}| = \sqrt{9 + 1} = \sqrt{10}$ and $|\vec{b}| = \sqrt{16 + 4} = \sqrt{20}$. **M1**

    $$\cos\theta = \dfrac{\vec{a}\cdot\vec{b}}{|\vec{a}||\vec{b}|} = \dfrac{10}{\sqrt{10}\cdot\sqrt{20}} = \dfrac{10}{\sqrt{200}} = \dfrac{1}{\sqrt{2}}.$$

    $\theta = \arccos\!\left(\dfrac{1}{\sqrt{2}}\right) = 45.0^{\circ}$. **A1**
  ANS
)

puts "  ✓ Created #{Question.where(topic: topic, question_type: 'written').count} maths written exemplars"
