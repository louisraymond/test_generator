class CreateLearningObjectives < ActiveRecord::Migration[7.1]
  def change
    create_table :learning_objectives do |t|
      t.references :topic, null: false, foreign_key: true
      t.string :category, null: false
      t.integer :category_order, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.text :description, null: false

      t.timestamps
    end

    create_table :question_learning_objectives do |t|
      t.references :question, null: false, foreign_key: true
      t.references :learning_objective, null: false, foreign_key: true

      t.timestamps
    end

    add_index :learning_objectives, [:topic_id, :category, :position]
    add_index :learning_objectives, [:topic_id, :category_order]
    add_index :question_learning_objectives, [:question_id, :learning_objective_id], unique: true, name: 'index_qlo_on_question_and_learning_objective'
  end
end
