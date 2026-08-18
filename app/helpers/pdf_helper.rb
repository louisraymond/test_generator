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

    # answer_size override. Prose sizes are calibrated against real
    # handwritten sittings — a 4-mark written answer occupies 2-4 lines,
    # so the region is ~marks + 1 lines, capped at 8. The old half-page
    # regions (lines--12/16/22) made short-answer papers mostly whitespace.
    case size
    when 'long'   then return prose ? 'lines lines--8' : 'workbox workbox--xl'
    when 'medium' then return prose ? 'lines lines--5' : 'workbox workbox--lg'
    when 'short'  then return prose ? 'lines lines--3' : 'lines lines--1'
    end

    if prose
      # Prose answers — ruled lines, no enclosing box.
      case marks
      when 0, 1 then 'lines lines--2'
      when 2    then 'lines lines--3'
      when 3    then 'lines lines--4'
      when 4    then 'lines lines--5'
      when 5    then 'lines lines--6'
      else           'lines lines--8'
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

  # --- height-aware page packing -------------------------------------------
  # The paper renders one .paper block per physical A4 page, so the view
  # must decide up front which questions share a page. These estimates are
  # deliberately conservative: an overestimate wastes a little paper, but an
  # underestimate overflows the 297mm sheet and shifts every later footer.
  # (.q carries page-break-inside: avoid, so the failure mode is a question
  # spilling wholesale to an unnumbered sheet — cosmetic, but avoid it.)

  # Constants calibrated against puppeteer-measured renders of real
  # questions (2026-08-18): line box 26px, flowing stems fit ~80 chars/line
  # (72 keeps a raggedness margin), per-question chrome ~34px incl. the
  # 18px margin-bottom, usable page = 983px content - runhead - runfoot
  # and their margins ≈ 913px.
  PAGE_BUDGET = 900             # px of question space per .paper (983px content - runhead/runfoot ≈ 913)
  SECTION_HEAD_COST = 80        # the section banner on a section's first page
  MAX_QUESTIONS_PER_PAGE = 6    # bounds estimator error on batches of tiny questions
  STEM_CHARS_PER_LINE = 88      # measured ~90 with the widest fallback font; Cormorant packs more
  TEXT_LINE = 26                # measured line box (em-based, so font-independent)
  PARAGRAPH_GAP = 6             # a blank markdown line renders as a paragraph margin, not a text line
  QUESTION_CHROME = 36          # measured 34: question number row + .q margin-bottom

  # Greedy packer: fill each page up to the budget, never splitting a
  # question. The first page of a section reserves room for its banner.
  # Returns an array of pages, each an array of exam_questions, in order.
  def pack_exam_questions(exam_questions, budget: PAGE_BUDGET)
    pages = []
    current = []
    used = 0
    page_budget = budget - SECTION_HEAD_COST
    exam_questions.each do |eq|
      h = estimated_question_height(eq.question)
      if current.any? && (used + h > page_budget || current.size >= MAX_QUESTIONS_PER_PAGE)
        pages << current
        current = []
        used = 0
        page_budget = budget
      end
      current << eq
      used += h
    end
    pages << current if current.any?
    pages
  end

  def estimated_question_height(question)
    h = QUESTION_CHROME + estimated_text_height(question.content)
    opts = question.options
    case question.question_type
    when 'multiple_choice', 'ordering', 'ranking'
      h + Array(opts).size * 30 + 10
    when 'matching'
      pairs = opts.is_a?(Hash) ? Array(opts['left']).size : 0
      h + pairs * 30 + 20
    when 'cloze'
      h + 20
    when 'code_analysis'
      o = opts.is_a?(Hash) ? opts : {}
      h + o['code'].to_s.lines.size * 20 + 40 + Array(o['choices']).size * 30
    when 'composite'
      parts = question.respond_to?(:question_parts) ? question.question_parts.size : 0
      parts = Array(opts).size if parts.zero?
      h + [parts, 1].max * (TEXT_LINE + 62) # part stem + two ruled lines each
    when 'diagram_label', 'image_occlusion'
      h + 500
    else
      h + workspace_height(question)
    end
  end

  # Pixel height of the answer region marks_to_workspace will emit,
  # including the calculation final-answer rule where it applies.
  def workspace_height(question)
    klass = marks_to_workspace(question)
    h = if (n = klass[/lines--(\d+)/, 1])
          # Exact height of the emitted ruling: 14px lead-in rule, 24px
          # pitch thereafter, 1px stroke each (matches measured renders).
          n = n.to_i
          14 + (n - 1) * 24 + n
        else
          { 'workbox--sm' => 120, 'workbox--md' => 200,
            'workbox--lg' => 350, 'workbox--xl' => 550 }.find { |k, _| klass.include?(k) }&.last || 550
        end
    if question.question_type.to_s == 'calculation' && (question.points.to_i >= 3 || question.answer_size == 'long')
      h += 44
    end
    h
  end

  def estimated_text_height(text)
    h = 0
    text.to_s.split("\n").each do |ln|
      if ln.strip.empty?
        h += PARAGRAPH_GAP
      else
        h += [(ln.length / STEM_CHARS_PER_LINE.to_f).ceil, 1].max * TEXT_LINE
      end
    end
    [h, TEXT_LINE].max
  end

  # Renders a prose answer region as stacked <hr class="rule-line"> strokes
  # inside its .lines--N container. Skia/PDF keeps borders as vector stroke
  # ops, so unlike the gradient background (stripped in @media print — see
  # paper.css), these rules survive into the printed paper without
  # rasterising. Workbox classes pass through as a plain (blank) div.
  def render_ruled_lines(workspace_class)
    count = workspace_class[/lines--(\d+)/, 1].to_i
    return tag.div(class: workspace_class) if count.zero? || workspace_class.include?('workbox')

    tag.div(class: "#{workspace_class} lines--ruled") do
      safe_join(Array.new(count) { tag.hr(class: 'rule-line') })
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
  # and recognising author markup for pre-blanked gaps. Both {{answer}} and
  # [[answer]] forms are accepted — earlier seeds standardised on
  # double-square-brackets; newer content uses double-curly.
  # Returns an array of { type:, text:, answer: } hashes where type is one of:
  #   :math        — verbatim math span, rendered raw (KaTeX picks it up)
  #   :autoblank   — pre-blanked gap from {{x}} or [[x]] markup; answer is
  #                  the inner text (stripped of leading/trailing whitespace)
  #   :word        — plain tokeniseable word (user can toggle via Stimulus)
  #   :space       — whitespace
  def tokenize_cloze(content)
    text = content.to_s
    tokens = []
    i = 0
    word_re = /\A[^\s${\[{]+/
    while i < text.length
      ch = text[i]
      if ch == '$'
        # Math span: $$...$$ preferred; fall back to $...$. Guard against
        # literal `$25` (currency) turning into math by requiring the
        # closing `$` not to be immediately followed by a digit and the
        # opening `$` not to be immediately preceded by a word char.
        if text[i, 2] == '$$' && (m = text[i..].match(/\A\$\$.*?\$\$/m))
          tokens << { type: :math, text: m[0] }
          i += m[0].length
        elsif (m = text[i..].match(/\A\$[^$\n\d][^$\n]*?\$(?![0-9])/)) &&
              !m[0].match?(/\[\[|\{\{/)
          # Extra guard: if the candidate span contains autoblank markup
          # ([[x]] or {{x}}), an author has almost certainly used `$` as
          # decoration rather than math. Fall through so the blanks survive.
          tokens << { type: :math, text: m[0] }
          i += m[0].length
        else
          tokens << { type: :word, text: ch }
          i += 1
        end
      elsif text[i, 2] == '{{' && (m = text[i..].match(/\A\{\{(.+?)\}\}/))
        tokens << { type: :autoblank, text: m[0], answer: m[1].strip }
        i += m[0].length
      elsif text[i, 2] == '[[' && (m = text[i..].match(/\A\[\[(.+?)\]\]/))
        tokens << { type: :autoblank, text: m[0], answer: m[1].strip }
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

  # Render a code snippet in the paper's printed code style — monospace
  # on warm beige, gutter line numbers, no syntax highlighting (paper is
  # meant to be calm and print-friendly, not an IDE). Matches the
  # `pre.code` + `.ln` markup spec'd in the design explorations.
  def render_paper_code(code, language: 'text', editable: false)
    return '' if code.to_s.empty?
    lines = code.to_s.split("\n")
    html = lines.each_with_index.map { |line, i|
      number = tag.span((i + 1).to_s, class: 'ln')
      line_body = if editable
                    tag.span(line.presence || ' ',
                             class: 'code__line',
                             'data-line-index': i,
                             'data-action': 'click->code-paper#toggleLine')
                  else
                    ERB::Util.html_escape(line)
                  end
      "#{number} #{line_body}"
    }.join("\n")
    tag.pre(raw(html), class: "code code--#{language} #{'code--editable' if editable}")
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
