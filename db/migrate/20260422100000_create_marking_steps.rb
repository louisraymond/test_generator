class CreateMarkingSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :marking_steps do |t|
      t.references :question, null: false, foreign_key: true
      t.integer :position, null: false
      t.string  :kind, null: false
      t.integer :n, null: false, default: 1
      t.text    :text, null: false
      t.text    :accepts, array: true, default: []
      t.text    :rejects, array: true, default: []
      t.text    :notes
      t.timestamps
    end
    add_index :marking_steps, %i[question_id position], unique: true
  end
end
