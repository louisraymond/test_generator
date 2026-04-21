class Question < ApplicationRecord
  ANSWER_SIZES = %w[short medium long].freeze
  QUESTION_TYPES = %w[
    written
    multiple_choice
    calculation
    matching
    cloze
    ordering
    ranking
    diagram_label
    image_occlusion
    composite
    markdown
    code_analysis
  ].freeze

  # Bloom's Revised Taxonomy (Anderson & Krathwohl, 2001) — ordered by
  # increasing cognitive demand. Stored verbatim as a string so the set can
  # evolve without a migration and so filters can use human-readable values.
  BLOOM_LEVELS = %w[remember understand apply analyze evaluate create].freeze

  attribute :options, :json, default: []
  attr_accessor :options_text

  belongs_to :topic
  belongs_to :topic_module, optional: true
  belongs_to :source, optional: true

  has_many :exam_questions, dependent: :destroy
  has_many :exams, through: :exam_questions
  has_many :question_learning_objectives, dependent: :destroy
  has_many :learning_objectives, through: :question_learning_objectives
  has_many :marking_steps, -> { ordered }, dependent: :destroy

  # True when the question has one or more structured credit events.
  # The mark-scheme renderer uses this to decide between the new card
  # layout (with M/A/B/DM pills) and the legacy free-text fallback.
  def has_structured_marking?
    marking_steps.any?
  end

  validates :content, :answer, :points, presence: true
  validates :points, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :question_type, inclusion: { in: QUESTION_TYPES }
  validates :answer_size, inclusion: { in: ANSWER_SIZES }, allow_nil: true
  validates :bloom_level, inclusion: { in: BLOOM_LEVELS }, allow_nil: true
  validate :options_requirements_for_type
  validate :learning_objectives_align_with_topic

  before_validation :apply_options_text

  private

  def options_requirements_for_type
    case question_type
    when 'multiple_choice'
      unless options.is_a?(Array) && options.length >= 2
        errors.add(:options, 'must include at least two choices')
        return
      end

      normalized = options.map do |option|
        case option
        when Hash
          { 'text' => option['text'] || option[:text], 'correct' => option['correct'] || option[:correct] }
        else
          nil
        end
      end

      if normalized.any?(&:nil?) || normalized.any? { |opt| opt['text'].to_s.strip.blank? }
        errors.add(:options, 'each choice must include text')
      end

      unless normalized.any? { |opt| ActiveModel::Type::Boolean.new.cast(opt['correct']) }
        errors.add(:options, 'must have at least one correct choice')
      end

      self.options = normalized
    when 'matching'
      unless options.is_a?(Hash) && options['left'].is_a?(Array) && options['right'].is_a?(Array)
        errors.add(:options, "must include 'left' and 'right' arrays")
      else
        errors.add(:options, 'left and right must be same length') unless options['left'].length == options['right'].length
      end
    when 'ordering'
      errors.add(:options, 'must be an array of 2 or more items') unless options.is_a?(Array) && options.length >= 2
    when 'ranking'
      unless options.is_a?(Array) && options.length >= 2
        errors.add(:options, 'must include at least two rankable items')
        return
      end

      normalized = options.each_with_index.map do |item, idx|
        if item.is_a?(Hash)
          text = item['text'] || item[:text]
          rank_value = item['rank'] || item[:rank]
          rank = rank_value.to_i
        else
          text = item.to_s
          rank = idx + 1
        end

        { 'text' => text, 'rank' => rank.positive? ? rank : idx + 1 }
      end

      if normalized.any? { |opt| opt['text'].to_s.strip.blank? }
        errors.add(:options, 'each option must include text')
      else
        self.options = normalized
      end
    when 'diagram_label'
      unless options.is_a?(Hash) && (options['image'].present? || options['labels'].is_a?(Array))
        errors.add(:options, "should include 'image' (asset path or URL) and 'labels' array")
      end
    when 'image_occlusion'
      unless options.is_a?(Hash) && options['image'].present?
        errors.add(:options, "should include 'image' and optional 'masks' array")
      end
    when 'cloze', 'composite'
      # validated via content presence and base rules; options shape flexible for now
    when 'code_analysis'
      unless options.is_a?(Hash)
        errors.add(:options, 'must be a hash with keys language, code, answer_format')
        return
      end

      if options['code'].to_s.strip.blank?
        errors.add(:options, "must include 'code'")
      end

      fmt = options['answer_format']
      unless %w[lines multiple_choice].include?(fmt)
        errors.add(:options, "answer_format must be 'lines' or 'multiple_choice'")
        return
      end

      if fmt == 'multiple_choice'
        choices = options['choices']
        unless choices.is_a?(Array) && choices.length >= 2
          errors.add(:options, 'multiple_choice requires at least 2 choices')
          return
        end

        unless choices.all? { |c| c.is_a?(Hash) && c['text'].to_s.strip.present? }
          errors.add(:options, 'each choice must include text')
        end

        unless choices.any? { |c| ActiveModel::Type::Boolean.new.cast(c['correct']) }
          errors.add(:options, 'at least one choice must be correct')
        end
      end
    end
  end

  def apply_options_text
    return unless instance_variable_defined?(:@options_text)

    text = @options_text
    return if text.nil?

    if text.strip.blank?
      self.options = []
      return
    end

    parsed = JSON.parse(text)
    self.options = parsed
  rescue JSON::ParserError => e
    errors.add(:options, "must be valid JSON (#{e.message})")
  end

  def learning_objectives_align_with_topic
    return if topic_id.blank?

    mismatched = learning_objectives.any? { |objective| objective.topic_id != topic_id }
    errors.add(:learning_objectives, 'must belong to the selected topic') if mismatched
  end
end
