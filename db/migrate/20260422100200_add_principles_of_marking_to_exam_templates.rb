class AddPrinciplesOfMarkingToExamTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :exam_templates, :principles_of_marking, :text
  end
end
