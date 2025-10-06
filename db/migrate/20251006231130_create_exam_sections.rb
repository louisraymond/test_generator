class CreateExamSections < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_sections do |t|
      t.references :exam_template, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :name, null: false
      t.integer :duration_minutes
      t.integer :question_count, null: false
      t.integer :min_points
      t.integer :max_points
      t.jsonb :question_type_filter, default: []

      t.timestamps
    end
    
    add_index :exam_sections, [:exam_template_id, :position]
  end
end
