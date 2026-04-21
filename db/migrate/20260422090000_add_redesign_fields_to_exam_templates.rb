class AddRedesignFieldsToExamTemplates < ActiveRecord::Migration[7.1]
  def change
    change_table :exam_templates, bulk: true do |t|
      t.string  :subject
      t.string  :paper_number
      t.string  :tier
      t.string  :subtitle
      t.text    :rubric
      t.jsonb   :candidate_fields, default: [], null: false
      t.jsonb   :grade_boundaries, default: {}, null: false
      t.string  :centre_name
      t.boolean :sections_have_letters, default: true, null: false
    end
  end
end
