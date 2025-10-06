class AddExamTemplateToExams < ActiveRecord::Migration[7.1]
  def change
    add_reference :exams, :exam_template, null: true, foreign_key: true
  end
end
