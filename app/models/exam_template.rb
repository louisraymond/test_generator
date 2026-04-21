class ExamTemplate < ApplicationRecord
  TIERS = %w[foundation higher standard].freeze

  has_many :exam_sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :exams, dependent: :nullify

  accepts_nested_attributes_for :exam_sections, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true
  validates :use_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :tier, inclusion: { in: TIERS }, allow_nil: true
  
  scope :recently_used, -> { where.not(last_used_at: nil).order(last_used_at: :desc) }
  scope :most_used, -> { where('use_count > 0').order(use_count: :desc) }
  
  def increment_use_count!
    self.class.where(id: id).update_all(
      ['use_count = use_count + 1, last_used_at = ?', Time.current]
    )
    reload
  end
  
  def total_questions
    exam_sections.sum(:question_count)
  end
  
  def total_duration
    duration_minutes || exam_sections.sum(:duration_minutes)
  end
end

