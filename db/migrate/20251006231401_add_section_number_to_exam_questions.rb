class AddSectionNumberToExamQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :exam_questions, :section_number, :integer
  end
end
