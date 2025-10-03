class Exam < ApplicationRecord
  has_many :exam_questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :questions, -> { order(Arel.sql('exam_questions.position ASC')) }, through: :exam_questions
end
