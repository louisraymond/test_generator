# frozen_string_literal: true

# Helpers for the paper-style PDF layouts (student paper + mark scheme).
# Keep this module small: *logic* lives here, markup lives in shared partials
# (`shared/_mark`, `exams/_cover_page`, etc).
module PdfHelper
  # Maps a question to a CSS class for its answer region.
  # Accepts either:
  #   - an integer (marks) — old signature, kept for back-compat
  #   - a Question instance — preferred; reads question_type + answer_size + points
  #
  # Prose question types (written, markdown) get *ruled lines* for
  # handwriting. Math types (calculation, everything else) get a blank
  # workbox suited to showing working.
  #
  # answer_size (short/medium/long) overrides the marks-based default.
  def marks_to_workspace(question_or_marks)
    if question_or_marks.respond_to?(:points)
      question = question_or_marks
      size = question.try(:answer_size).to_s
      marks = question.points.to_i
      type = question.try(:question_type).to_s
    else
      question = nil
      size = ''
      marks = question_or_marks.to_i
      type = ''
    end

    prose = %w[written markdown composite].include?(type)

    # answer_size override
    case size
    when 'long'   then return prose ? 'lines lines--22' : 'workbox workbox--xl'
    when 'medium' then return prose ? 'lines lines--12' : 'workbox workbox--lg'
    when 'short'  then return 'lines lines--1'
    end

    if prose
      # Prose answers — ruled lines, no enclosing box.
      case marks
      when 0, 1 then 'lines lines--4'
      when 2    then 'lines lines--6'
      when 3    then 'lines lines--10'
      when 4    then 'lines lines--16'
      else           'lines lines--22'    # 550-ish px ≈ half-page ruled
      end
    else
      # Math / calculation — blank working box.
      case marks
      when 0    then 'lines lines--2'
      when 1    then 'workbox workbox--sm'
      when 2    then 'workbox workbox--md'
      when 3    then 'workbox workbox--lg'
      else           'workbox workbox--xl'
      end
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

  # Tokenise cloze stem content preserving KaTeX math spans ($...$ and $$...$$)
  # and recognising the author's {{answer}} markup as a pre-blanked gap.
  # Returns an array of { type:, text:, answer: } hashes where type is one of:
  #   :math        — verbatim math span, rendered raw (KaTeX picks it up)
  #   :autoblank   — pre-blanked gap from {{x}} markup; answer is the inner text
  #   :word        — plain tokeniseable word (user can toggle via Stimulus)
  #   :space       — whitespace
  def tokenize_cloze(content)
    text = content.to_s
    tokens = []
    i = 0
    word_re = /\A[^\s${]+/
    while i < text.length
      ch = text[i]
      if ch == '$'
        # Math span: $$...$$ preferred; fall back to $...$
        if text[i, 2] == '$$' && (m = text[i..].match(/\A\$\$.*?\$\$/m))
          tokens << { type: :math, text: m[0] }
          i += m[0].length
        elsif (m = text[i..].match(/\A\$[^$\n]+?\$/))
          tokens << { type: :math, text: m[0] }
          i += m[0].length
        else
          tokens << { type: :word, text: ch }
          i += 1
        end
      elsif text[i, 2] == '{{' && (m = text[i..].match(/\A\{\{(.+?)\}\}/))
        tokens << { type: :autoblank, text: m[0], answer: m[1] }
        i += m[0].length
      elsif ch =~ /\s/
        tokens << { type: :space, text: ch }
        i += 1
      elsif (m = text[i..].match(word_re))
        tokens << { type: :word, text: m[0] }
        i += m[0].length
      else
        tokens << { type: :word, text: ch }
        i += 1
      end
    end
    tokens
  end

  # Eyebrow text shown above the cover title: "SUBJECT · PAPER N · TIER".
  # When subject/paper/tier are unset (legacy exams from before the
  # redesign), falls back to showing just the exam date so the cover
  # doesn't read as a generic "Examination paper" every time.
  def paper_eyebrow(exam)
    parts = []
    parts << exam.subject.to_s.upcase if exam.subject.present?
    parts << "Paper #{exam.paper_number}" if exam.paper_number.present?
    parts << exam.tier.to_s.capitalize if exam.tier.present?
    return parts.join(' · ') if parts.any?

    date = exam.exam_date || exam.created_at.to_date
    "Exam · #{date.strftime('%B %Y').upcase}"
  end
end
