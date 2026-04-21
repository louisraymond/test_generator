class AddSectionLetterToExamSections < ActiveRecord::Migration[7.1]
  def up
    add_column :exam_sections, :letter, :string

    # Backfill A, B, C, ... based on position within each template.
    ExamSection.reset_column_information
    ExamSection.order(:exam_template_id, :position).each do |section|
      letter = (('A'.ord) + section.position.to_i).chr
      section.update_columns(letter: letter)
    end
  end

  def down
    remove_column :exam_sections, :letter
  end
end
