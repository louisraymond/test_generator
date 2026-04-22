# Small view-level helpers for the Question editor chrome (Wave 5).
module QuestionTypesHelper
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
