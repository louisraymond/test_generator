class ExamQuestion < ApplicationRecord
  belongs_to :exam
  belongs_to :question

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
