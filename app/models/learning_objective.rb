class LearningObjective < ApplicationRecord
  belongs_to :topic
  belongs_to :topic_module, optional: true

  has_many :question_learning_objectives, dependent: :destroy
  has_many :questions, through: :question_learning_objectives

  validates :category, presence: true
  validates :description, presence: true

  # Number of distinct exams that have included a question targeting this LO.
  # Returns 0 without touching exams when the LO has no questions.
  def exam_appearance_count
    return 0 unless question_learning_objectives.exists?

    ExamQuestion
      .joins(question: :question_learning_objectives)
      .where(question_learning_objectives: { learning_objective_id: id })
      .distinct
      .count(:exam_id)
  end
end
