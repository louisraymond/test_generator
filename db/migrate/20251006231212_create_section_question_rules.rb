class CreateSectionQuestionRules < ActiveRecord::Migration[7.1]
  def change
    create_table :section_question_rules do |t|
      t.references :exam_section, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :rule_type, null: false
      t.integer :repeat_count, default: 1, null: false

      t.timestamps
    end
    
    add_index :section_question_rules, [:exam_section_id, :question_id, :rule_type], 
              name: 'index_section_question_rules_on_section_question_type'
  end
end
