class FixSourceIdType < ActiveRecord::Migration[7.1]
  def up
    change_column :section_source_rules, :source_id, :bigint
  end

  def down
    change_column :section_source_rules, :source_id, :integer
  end
end
