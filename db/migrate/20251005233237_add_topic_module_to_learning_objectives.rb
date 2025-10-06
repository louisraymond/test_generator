class AddTopicModuleToLearningObjectives < ActiveRecord::Migration[7.1]
  def change
    add_reference :learning_objectives, :topic_module, null: true, foreign_key: true
  end
end
