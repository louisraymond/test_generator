class QuestionLearningObjective < ApplicationRecord
  belongs_to :question
  belongs_to :learning_objective

  validates :question_id, uniqueness: { scope: :learning_objective_id }
end
