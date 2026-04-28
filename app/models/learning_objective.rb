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

  # Bulk variant of #exam_appearance_count.
  # Returns { lo_id => distinct_exam_count } in a single query.
  # Callers should access the hash with .fetch(lo_id, 0) — keys for LOs with
  # zero exam appearances are omitted from the result.
  #
  # `scope` may be an ActiveRecord relation (composed as a subquery — single
  # round-trip) or an Array of LearningObjective records (mapped to ids).
  def self.exam_appearance_counts_for(scope)
    id_filter =
      if scope.is_a?(ActiveRecord::Relation)
        scope.unscope(:order).select(:id)
      else
        Array(scope).map(&:id)
      end

    return {} if id_filter.is_a?(Array) && id_filter.empty?

    joins(question_learning_objectives: { question: :exam_questions })
      .where(id: id_filter)
      .group('learning_objectives.id')
      .distinct
      .count('exam_questions.exam_id')
  end
end
