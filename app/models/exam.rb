class Exam < ApplicationRecord
  self.locking_column = :lock_version

  belongs_to :exam_template, optional: true
  has_many :exam_questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :questions, -> { order(Arel.sql('exam_questions.position ASC')) }, through: :exam_questions

  validates :title, presence: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  before_validation :assign_random_seed, on: :create

  # Group exam questions by section
  def questions_by_section
    exam_questions.group_by(&:section_number)
  end

  # Get section information if exam was generated from template
  def section_info(section_number)
    return nil unless exam_template
    exam_template.exam_sections.find_by(position: section_number)
  end

  # Template-inherited fields with per-exam override precedence. Returning nil
  # when neither the override nor the template is set keeps callers (cover-page
  # partial) tolerant of ad-hoc exams created without a template.
  %i[subject paper_number tier centre_name].each do |field|
    override = :"#{field}_override"
    define_method(field) do
      self[override].presence || exam_template&.public_send(field)
    end
  end

  def total_marks
    exam_questions.joins(:question).sum('questions.points')
  end

  private

  def assign_random_seed
    self.seed ||= SecureRandom.random_number(10_000)
  end
end
