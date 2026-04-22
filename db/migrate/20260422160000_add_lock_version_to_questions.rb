class AddLockVersionToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :lock_version, :integer, default: 0, null: false
  end
end
