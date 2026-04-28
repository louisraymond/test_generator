# Small view-level helpers for the Question editor chrome (Wave 5).
module QuestionTypesHelper
  # Adapter that wraps a composite-part hash so the existing standalone
  # per-type partials (`_calculation.html.erb`, `_multiple_choice.html.erb`,
  # `_markdown.html.erb`, etc.) can render a sub-part without us having to
  # re-implement their layout.
  #
  # Editor #9 / design contract item 3: "Composite parts MUST embed the
  # standalone per-type renderers, not re-implement them."
  CompositePartAdapter = Struct.new(:part, :parent_id, :index) do
    def id
      "#{parent_id}-p#{index}"
    end

    def content
      part['stem'].to_s
    end

    def answer_label
      part['answer_label']
    end

    def unit
      part['unit']
    end

    def options
      part['options']
    end

    def answer_size
      part['answer_size']
    end

    def question_type
      part['type']
    end

    def points
      part['marks']
    end
  end

  # Public: build a Question-shaped adapter for one composite part.
  def composite_part_question(question, part, index)
    CompositePartAdapter.new(part, question.id, index)
  end

  # Editor #50 — return composite parts as hashes (the legacy jsonb shape)
  # whether they live in QuestionPart AR rows or in `options['parts']` jsonb.
  # AR wins when present; falls back to jsonb only when AR is empty. This
  # keeps `_cm_composite.html.erb` shape-stable: every consumer sees the
  # same hash, regardless of source. Pattern mirrored from
  # `app/views/exams/_paper_question.html.erb` lines 266-280.
  def composite_parts(question)
    ar = question.question_parts.ordered.to_a
    return _jsonb_composite_parts(question) if ar.empty?

    ar.map { |p| _question_part_to_hash(p) }
  end

  # Internal — flatten AR row to the jsonb shape consumers already expect.
  def _question_part_to_hash(part)
    opts = part.options.is_a?(Hash) ? part.options : {}
    {
      'type'         => part.part_type,
      'stem'         => part.stem.to_s,
      'marks'        => part.marks,
      'answer_label' => part.answer_label,
      'unit'         => part.unit,
      'answer_size'  => opts['answer_size'],
      # Strip the answer_size key out of options when it's mirrored at the
      # top level so the rest of the partial sees the same shape as a jsonb
      # part (which puts answer_size as a sibling, not nested under options).
      'options'      => opts.except('answer_size'),
    }
  end

  def _jsonb_composite_parts(question)
    return [] unless question.options.is_a?(Hash)
    Array(question.options['parts'])
  end

  # One-line blurb shown under each type card on the picker screen.
  # Kept here (not on the Descriptor) because it's purely presentational.
  def q_picker_blurb(key)
    {
      'multiple_choice' => 'Click an option on the paper to mark it correct.',
      'cloze'           => 'Click a word in the stem to blank it.',
      'matching'        => 'Left column stays ordered; right column shuffles from a seed.',
      'ordering'        => 'Author orders the items; the paper shuffles them.',
      'ranking'         => 'Like ordering but asks for a rank label per item.',
      'calculation'     => 'Prose stem with a ruled working box scaled by marks.',
      'written'         => 'Free-form prose answer with ruled lines.',
      'markdown'        => 'Markdown-rich stem; same answer shape as written.',
      'composite'       => '(a) (b) (c) sub-parts — nest with Tab.',
      'code_analysis'   => 'Fenced code snippet; click a line to mark it highlighted.',
      'diagram_label'   => 'Upload a figure; click to drop numbered pins.',
      'image_occlusion' => 'Drag rectangles over regions to hide and re-reveal.'
    }[key.to_s] || 'Paper-is-editor question type.'
  end
end
