class HardenDbConstraints < ActiveRecord::Migration[7.1]
  def up
    # Ensure questions.options has a DB default and is NOT NULL
    change_column_default :questions, :options, from: nil, to: []
    execute "UPDATE questions SET options = '[]'::jsonb WHERE options IS NULL"
    change_column_null :questions, :options, false

    # Strengthen exam_questions uniqueness
    remove_index :exam_questions, column: %i[exam_id position], if_exists: true
    add_index :exam_questions, %i[exam_id position], unique: true, name: 'index_exam_questions_on_exam_id_and_position'
    add_index :exam_questions, %i[exam_id question_id], unique: true, name: 'index_exam_questions_on_exam_id_and_question_id'
  end

  def down
    remove_index :exam_questions, name: 'index_exam_questions_on_exam_id_and_question_id', if_exists: true
    remove_index :exam_questions, name: 'index_exam_questions_on_exam_id_and_position', if_exists: true
    add_index :exam_questions, %i[exam_id position], name: 'index_exam_questions_on_exam_id_and_position'

    change_column_null :questions, :options, true
    change_column_default :questions, :options, from: [], to: nil
  end
end

