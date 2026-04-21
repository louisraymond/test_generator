class AddRedesignFieldsToExams < ActiveRecord::Migration[7.1]
  def change
    change_table :exams, bulk: true do |t|
      t.date    :exam_date
      t.integer :seed
      t.string  :subject_override
      t.string  :paper_number_override
      t.string  :tier_override
      t.string  :centre_name_override
      t.integer :lock_version, default: 0, null: false
    end
  end
end
