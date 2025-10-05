class AddOutlineFieldsToTopics < ActiveRecord::Migration[7.1]
  def change
    change_table :topics, bulk: true do |t|
      t.text :epigraph_quote
      t.string :epigraph_attribution
      t.jsonb :module_aims, default: [], null: false
      t.jsonb :learning_outcomes, default: [], null: false
      t.jsonb :syllabus_outline, default: [], null: false
      t.jsonb :reference_links, default: [], null: false
      t.references :parent_topic, foreign_key: { to_table: :topics }
    end
  end
end
