# Type registry — single source of truth for the 12 question types.
# Eliminates the `Question::QUESTION_TYPES.each do |t| ... end` scatter across
# views/controllers by attaching a Descriptor to every key with the partial
# paths, Stimulus controller, options value object, feature flag, and icon.
#
# Callsites:
#   QuestionTypes.all               # [Descriptor, ...]
#   QuestionTypes.for('mcq_like')   # Descriptor | nil
#   QuestionTypes.keys              # ['written', 'multiple_choice', ...]
#   QuestionTypes.grouped           # { choice: [...], written: [...], interactive: [...] }
module QuestionTypes
  Descriptor = Data.define(
    :key,
    :label,
    :icon,
    :group,
    :classic_form_partial,
    :paper_partial,
    :rail_content_partial,
    :rail_marking_partial,
    :rail_metadata_partial,
    :paper_controller,
    :options_class,
    :has_structured_marking,
    :has_image,
    :feature_flag
  )

  REGISTRY = [
    Descriptor.new(
      key: 'written', label: 'Written', icon: '✎',
      group: :written,
      classic_form_partial: 'questions/types/written',
      paper_partial: 'questions/written',
      rail_content_partial: 'exam_questions/rail/written_content',
      rail_marking_partial: 'exam_questions/rail/written_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'written-paper',
      options_class: QuestionOptions::WrittenOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :written
    ),
    Descriptor.new(
      key: 'multiple_choice', label: 'Multiple choice', icon: '◎',
      group: :choice,
      classic_form_partial: 'questions/types/multiple_choice',
      paper_partial: 'questions/multiple_choice',
      rail_content_partial: 'exam_questions/rail/mcq_content',
      rail_marking_partial: 'exam_questions/rail/mcq_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'mcq-paper',
      options_class: QuestionOptions::MCQOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :mcq
    ),
    Descriptor.new(
      key: 'calculation', label: 'Calculation', icon: '∑',
      group: :written,
      classic_form_partial: 'questions/types/calculation',
      paper_partial: 'questions/calculation',
      rail_content_partial: 'exam_questions/rail/calc_content',
      rail_marking_partial: 'exam_questions/rail/calc_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'calc-paper',
      options_class: QuestionOptions::CalculationOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :calculation
    ),
    Descriptor.new(
      key: 'matching', label: 'Matching', icon: '⇌',
      group: :interactive,
      classic_form_partial: 'questions/types/matching',
      paper_partial: 'questions/matching',
      rail_content_partial: 'exam_questions/rail/match_content',
      rail_marking_partial: 'exam_questions/rail/match_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'match-paper',
      options_class: QuestionOptions::MatchingOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :matching
    ),
    Descriptor.new(
      key: 'cloze', label: 'Cloze', icon: '▱',
      group: :interactive,
      classic_form_partial: 'questions/types/cloze',
      paper_partial: 'questions/cloze',
      rail_content_partial: 'exam_questions/rail/cloze_content',
      rail_marking_partial: 'exam_questions/rail/cloze_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'cloze-paper',
      options_class: QuestionOptions::ClozeOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :cloze
    ),
    Descriptor.new(
      key: 'ordering', label: 'Ordering', icon: '↕',
      group: :interactive,
      classic_form_partial: 'questions/types/ordering',
      paper_partial: 'questions/ordering',
      rail_content_partial: 'exam_questions/rail/order_content',
      rail_marking_partial: 'exam_questions/rail/order_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'order-paper',
      options_class: QuestionOptions::OrderingOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :ordering
    ),
    Descriptor.new(
      key: 'ranking', label: 'Ranking', icon: '#',
      group: :interactive,
      classic_form_partial: 'questions/types/ranking',
      paper_partial: 'questions/ranking',
      rail_content_partial: 'exam_questions/rail/rank_content',
      rail_marking_partial: 'exam_questions/rail/rank_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'order-paper',
      options_class: QuestionOptions::RankingOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :ranking
    ),
    Descriptor.new(
      key: 'diagram_label', label: 'Diagram label', icon: '◉',
      group: :interactive,
      classic_form_partial: 'questions/types/diagram_label',
      paper_partial: 'questions/diagram_label',
      rail_content_partial: 'exam_questions/rail/diagram_content',
      rail_marking_partial: 'exam_questions/rail/diagram_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'diagram-paper',
      options_class: QuestionOptions::DiagramLabelOptions,
      has_structured_marking: true, has_image: true,
      feature_flag: :diagram_label
    ),
    Descriptor.new(
      key: 'image_occlusion', label: 'Image occlusion', icon: '▢',
      group: :interactive,
      classic_form_partial: 'questions/types/image_occlusion',
      paper_partial: 'questions/image_occlusion',
      rail_content_partial: 'exam_questions/rail/occlusion_content',
      rail_marking_partial: 'exam_questions/rail/occlusion_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'occlusion-paper',
      options_class: QuestionOptions::ImageOcclusionOptions,
      has_structured_marking: true, has_image: true,
      feature_flag: :image_occlusion
    ),
    Descriptor.new(
      key: 'composite', label: 'Composite', icon: '❐',
      group: :written,
      classic_form_partial: 'questions/types/composite',
      paper_partial: 'questions/composite',
      rail_content_partial: 'exam_questions/rail/composite_content',
      rail_marking_partial: 'exam_questions/rail/composite_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'composite-paper',
      options_class: QuestionOptions::CompositeOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :composite
    ),
    Descriptor.new(
      key: 'markdown', label: 'Markdown', icon: 'Ⓜ',
      group: :written,
      classic_form_partial: 'questions/types/markdown',
      paper_partial: 'questions/markdown',
      rail_content_partial: 'exam_questions/rail/markdown_content',
      rail_marking_partial: 'exam_questions/rail/written_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'composite-paper',
      options_class: QuestionOptions::MarkdownOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :markdown
    ),
    Descriptor.new(
      key: 'code_analysis', label: 'Code analysis', icon: '‹›',
      group: :interactive,
      classic_form_partial: 'questions/types/code_analysis',
      paper_partial: 'questions/code_analysis',
      rail_content_partial: 'exam_questions/rail/code_content',
      rail_marking_partial: 'exam_questions/rail/code_marking',
      rail_metadata_partial: 'exam_questions/rail/common_metadata',
      paper_controller: 'code-paper',
      options_class: QuestionOptions::CodeAnalysisOptions,
      has_structured_marking: true, has_image: false,
      feature_flag: :code_analysis
    )
  ].freeze

  def self.all
    REGISTRY
  end

  def self.for(key)
    REGISTRY.find { |d| d.key == key.to_s }
  end

  def self.keys
    REGISTRY.map(&:key)
  end

  def self.grouped
    REGISTRY.group_by(&:group)
  end

  def self.enabled?(key)
    descriptor = self.for(key)
    flag = descriptor&.feature_flag
    return true if flag.nil?
    cfg = Rails.application.config.x.paper_editor
    return true unless cfg.respond_to?(flag)
    !!cfg.public_send(flag)
  end
end
