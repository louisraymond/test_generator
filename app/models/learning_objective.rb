class LearningObjective < ApplicationRecord
  belongs_to :topic

  has_many :question_learning_objectives, dependent: :destroy
  has_many :questions, through: :question_learning_objectives

  validates :category, presence: true
  validates :description, presence: true
end
