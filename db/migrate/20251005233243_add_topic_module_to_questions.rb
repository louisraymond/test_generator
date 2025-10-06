class AddTopicModuleToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_reference :questions, :topic_module, null: true, foreign_key: true
  end
end
