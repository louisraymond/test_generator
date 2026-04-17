# frozen_string_literal: true
#
# Maths exemplar — CLOZE question with LaTeX in the prompt.
# Proves the `(?<!\\)` lookbehind cloze regex fix in _question.html.erb
# doesn't clobber LaTeX `\[...\]` inside cloze content.

topic    = Topic.find_by!(name: 'Maths - Exemplars (v1 sampler)')
fn_cloze = topic.topic_modules.find_by!(name: 'Function Notation (cloze)')

claude = Source.find_by(name: 'Claude (claude-opus-4-7, 2026)')

puts '  - Maths cloze exemplars...'

# 15. Function notation recap
Question.create!(
  topic: topic, topic_module: fn_cloze, source: claude,
  source_reference: 'Original — function notation recap',
  question_type: 'cloze',
  answer_size: 'short',
  points: 2,
  content: <<~'CON'.strip,
    Given $f(x) = \sin x$: the derivative is {{cos x}} and the indefinite integral is {{-cos x + C}}.
  CON
  answer: "$f'(x) = \\cos x$; $\\int \\sin x\\,\\mathrm{d}x = -\\cos x + C$.",
  options: []
)

puts "  ✓ Created #{Question.where(topic: topic, question_type: 'cloze').count} maths cloze exemplars"
