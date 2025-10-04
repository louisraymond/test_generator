class AllowRepeatedQuestionsInExam < ActiveRecord::Migration[7.1]
  def up
    remove_index :exam_questions, name: 'index_exam_questions_on_exam_id_and_question_id', if_exists: true
  end

  def down
    add_index :exam_questions, %i[exam_id question_id], unique: true, name: 'index_exam_questions_on_exam_id_and_question_id'
  end
end

