class Exam < ApplicationRecord
  belongs_to :exam_template, optional: true
  has_many :exam_questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :questions, -> { order(Arel.sql('exam_questions.position ASC')) }, through: :exam_questions

  validates :title, presence: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # Group exam questions by section
  def questions_by_section
    exam_questions.group_by(&:section_number)
  end
  
  # Get section information if exam was generated from template
  def section_info(section_number)
    return nil unless exam_template
    exam_template.exam_sections.find_by(position: section_number)
  end
end
