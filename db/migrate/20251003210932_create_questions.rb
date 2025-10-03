class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.references :topic, null: false, foreign_key: true
      t.references :source, null: true, foreign_key: true
      t.text :content, null: false
      t.text :answer, null: false
      t.integer :points, null: false
      t.string :answer_size
      t.string :question_type
      t.jsonb :options
      t.string :source_reference
      t.string :answer_label
      t.string :unit

      t.timestamps
    end
  end
end
