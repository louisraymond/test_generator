class AddUniqueConstraintToTopicModules < ActiveRecord::Migration[7.1]
  def change
    add_index :topic_modules, [:topic_id, :name], unique: true, name: 'index_topic_modules_on_topic_id_and_name'
  end
end
