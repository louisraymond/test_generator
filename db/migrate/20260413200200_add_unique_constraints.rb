class AddUniqueConstraints < ActiveRecord::Migration[7.1]
  def change
    # exam_templates.name — model validates uniqueness but index is non-unique
    remove_index :exam_templates, :name
    add_index :exam_templates, :name, unique: true

    # exam_sections position should be unique within template
    remove_index :exam_sections, [:exam_template_id, :position]
    add_index :exam_sections, [:exam_template_id, :position], unique: true

    # section_question_rules — model validates uniqueness: { scope: [:exam_section_id, :rule_type] }
    remove_index :section_question_rules,
                 name: 'index_section_question_rules_on_section_question_type'
    add_index :section_question_rules,
              [:exam_section_id, :question_id, :rule_type],
              unique: true,
              name: 'idx_section_question_rules_unique'
  end
end
