class AddMarkerNotesToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :marker_notes, :text
  end
end
