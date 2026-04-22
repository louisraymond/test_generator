class AddPolymorphicCreditableToMarkingSteps < ActiveRecord::Migration[7.1]
  def change
    add_reference :marking_steps,
                  :creditable,
                  polymorphic: true,
                  null: true,
                  index: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE marking_steps
             SET creditable_type = 'Question',
                 creditable_id   = question_id
           WHERE creditable_id IS NULL
        SQL
      end
    end
  end
end
