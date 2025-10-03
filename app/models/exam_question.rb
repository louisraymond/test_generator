class ExamQuestion < ApplicationRecord
  belongs_to :exam
  belongs_to :question
end
