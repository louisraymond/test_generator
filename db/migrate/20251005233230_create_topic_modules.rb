class CreateTopicModules < ActiveRecord::Migration[7.1]
  def change
    create_table :topic_modules do |t|
      t.string :name
      t.text :description
      t.references :topic, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
