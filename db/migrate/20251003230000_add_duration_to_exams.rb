class AddDurationToExams < ActiveRecord::Migration[7.1]
  def change
    add_column :exams, :duration_minutes, :integer
  end
end

