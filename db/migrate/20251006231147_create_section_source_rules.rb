class CreateSectionSourceRules < ActiveRecord::Migration[7.1]
  def change
    create_table :section_source_rules do |t|
      t.references :exam_section, null: false, foreign_key: true
      t.string :source_type, null: false
      t.integer :source_id, null: false
      t.integer :weight, default: 1
      t.integer :question_count_override

      t.timestamps
    end
    
    add_index :section_source_rules, [:source_type, :source_id]
  end
end
