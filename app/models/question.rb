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
  ].freeze

  attribute :options, :json, default: []

  belongs_to :topic
  belongs_to :source, optional: true

  has_many :exam_questions, dependent: :destroy
  has_many :exams, through: :exam_questions

  validates :content, :answer, :points, presence: true
  validates :points, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :question_type, inclusion: { in: QUESTION_TYPES }
  validates :answer_size, inclusion: { in: ANSWER_SIZES }, allow_nil: true

  validate :options_requirements_for_type

  private

  def options_requirements_for_type
    case question_type
    when 'multiple_choice'
      errors.add(:options, 'must be a non-empty array') unless options.is_a?(Array) && options.any?
    when 'matching'
      unless options.is_a?(Hash) && options['left'].is_a?(Array) && options['right'].is_a?(Array)
        errors.add(:options, "must include 'left' and 'right' arrays")
      else
        errors.add(:options, 'left and right must be same length') unless options['left'].length == options['right'].length
      end
    when 'ordering', 'ranking'
      errors.add(:options, 'must be an array of 2 or more items') unless options.is_a?(Array) && options.length >= 2
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
    end
  end
end
