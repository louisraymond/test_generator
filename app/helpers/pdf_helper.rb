# frozen_string_literal: true

# Helpers for the paper-style PDF layouts (student paper + mark scheme).
# Keep this module small: *logic* lives here, markup lives in shared partials
# (`shared/_mark`, `exams/_cover_page`, etc).
module PdfHelper
  # Maps a question to a CSS class for its answer region.
  # Accepts either:
  #   - an integer (marks) — old signature, kept for back-compat
  #   - a Question instance — preferred; reads answer_size + points
  #
  # answer_size (short/medium/long) overrides the marks-based default, so
  # authors can say "this 2-mark question is a derivation — give it a box"
  # without inflating the mark value.
  #
  # Marks-based fallback (revised after feedback that 4 marks was too small):
  #   1 mark   → one ruled line
  #   2 marks  → two ruled lines
  #   3 marks  → medium working box (88px)
  #   4 marks  → large working box (140px)
  #   5+ marks → extra-large working box (190px), usually paired with .finalans
  def marks_to_workspace(question_or_marks)
    size, marks = if question_or_marks.respond_to?(:points)
                    [question_or_marks.try(:answer_size), question_or_marks.points.to_i]
                  else
                    [nil, question_or_marks.to_i]
                  end

    case size.to_s
    when 'long'   then return 'workbox workbox--xl'
    when 'medium' then return 'workbox workbox--lg'
    when 'short'  then return 'lines lines--1'
    end

    # Marks → workspace (revised for maths: every question gets a real
    # working box, and anything 4+ marks is half-page minimum).
    case marks
    when 0    then 'lines lines--2'
    when 1    then 'workbox workbox--sm'   # 120px — ~5 lines
    when 2    then 'workbox workbox--md'   # 200px
    when 3    then 'workbox workbox--lg'   # 350px
    else           'workbox workbox--xl'   # 550px half-page default for 4+ marks
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
