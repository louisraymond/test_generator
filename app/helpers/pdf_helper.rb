# frozen_string_literal: true

# Helpers for the paper-style PDF layouts (student paper + mark scheme).
# Keep this module small: *logic* lives here, markup lives in shared partials
# (`shared/_mark`, `exams/_cover_page`, etc).
module PdfHelper
  # Maps a question's mark total to a CSS class for its answer region.
  #   1-2 marks  → ruled lines
  #   3-4 marks  → small/medium working box
  #   5+ marks   → large working box (caller is expected to append a .finalans)
  def marks_to_workspace(marks)
    case marks.to_i
    when 0, 1 then 'lines lines--1'
    when 2    then 'lines lines--2'
    when 3    then 'workbox workbox--sm'
    when 4    then 'workbox workbox--md'
    else           'workbox workbox--lg'
    end
  end

  # Renders a "Final answer: ___ unit" rule. Omit unit: to skip the unit span.
  def render_final_answer(label:, unit: nil)
    tag.div(class: 'finalans') do
      out = tag.span(label, class: 'finalans__label')
      out += tag.span('', class: 'finalans__line')
      out += tag.span(unit, class: 'finalans__unit') if unit.present?
      out
    end
  end

  # Credit pill primitive (M1 / A1 / B1 / DM1). Use this rather than writing
  # the span by hand so the palette stays consistent across markup.
  def render_mark(kind:, n: 1)
    k = kind.to_s.downcase
    tag.span("#{k.upcase}#{n}", class: "mark mark--#{k}")
  end

  # Deterministic MCQ shuffle keyed by exam seed + question id (optional).
  # Same seed produces the same order — essential for candidates sitting the
  # same paper.
  def shuffled_mcq_options(options, seed:)
    return options if options.blank?
    options.shuffle(random: Random.new(seed.to_i))
  end

  # Eyebrow text shown above the cover title: "SUBJECT · PAPER N · TIER".
  def paper_eyebrow(exam)
    parts = []
    parts << exam.subject.to_s.upcase if exam.subject.present?
    parts << "Paper #{exam.paper_number}" if exam.paper_number.present?
    parts << exam.tier.to_s.capitalize if exam.tier.present?
    parts.compact.join(' · ')
  end
end
