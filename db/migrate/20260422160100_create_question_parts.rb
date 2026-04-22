class CreateQuestionParts < ActiveRecord::Migration[7.1]
  def change
    create_table :question_parts do |t|
      t.references :question, null: false, foreign_key: true, index: true
      t.references :parent_part, null: true,
                   foreign_key: { to_table: :question_parts }
      t.integer :position, null: false
      t.string  :part_type, null: false
      t.string  :label
      t.text    :stem
      t.text    :model_answer
      t.integer :marks, default: 1, null: false
      t.string  :answer_label
      t.string  :unit
      t.jsonb   :options, default: {}, null: false
      t.timestamps
    end

    add_index :question_parts,
              [:question_id, :parent_part_id, :position],
              name: 'idx_parts_per_parent_order'
  end
end
