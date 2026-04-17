class AddBloomLevelToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :bloom_level, :string
    add_index :questions, :bloom_level
  end
end
