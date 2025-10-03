class CreateSources < ActiveRecord::Migration[7.1]
  def change
    create_table :sources do |t|
      t.string :name
      t.string :source_type
      t.text :notes

      t.timestamps
    end
  end
end
