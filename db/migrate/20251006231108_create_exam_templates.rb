class CreateExamTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_templates do |t|
      t.string :name, null: false
      t.text :description
      t.integer :duration_minutes
      t.integer :use_count, default: 0, null: false
      t.datetime :last_used_at

      t.timestamps
    end
    
    add_index :exam_templates, :name
    add_index :exam_templates, :last_used_at
  end
end
