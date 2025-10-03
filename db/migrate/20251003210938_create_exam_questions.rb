class CreateExamQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_questions do |t|
      t.references :exam, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :exam_questions, [:exam_id, :position]
  end
end
