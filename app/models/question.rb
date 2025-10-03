class Question < ApplicationRecord
  attribute :options, :json, default: []

  belongs_to :topic
  belongs_to :source, optional: true

  has_many :exam_questions, dependent: :destroy
  has_many :exams, through: :exam_questions

  validates :content, :answer, :points, presence: true
end
