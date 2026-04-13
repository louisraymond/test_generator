class HardenConstraintsRoundTwo < ActiveRecord::Migration[7.1]
  def up
    # Backfill before adding constraints
    Question.where(question_type: [nil, '']).update_all(question_type: 'written')
    ExamQuestion.where(position: nil).find_each { |eq| eq.update_column(:position, eq.id) }
    TopicModule.where(name: [nil, '']).update_all(name: 'Unnamed Module')
    TopicModule.where(position: nil).update_all(position: 0)
    Source.where(name: [nil, '']).update_all(name: 'Unknown')
    Source.where(source_type: [nil, '']).update_all(source_type: 'book')
    Exam.where(title: [nil, '']).update_all(title: 'Practice Exam')

    # NOT NULL constraints
    change_column_null :questions, :question_type, false
    change_column_null :exam_questions, :position, false
    change_column_null :topic_modules, :name, false
    change_column_null :topic_modules, :position, false
    change_column_null :sources, :name, false
    change_column_null :sources, :source_type, false
    change_column_null :exams, :title, false

    # Missing performance indexes
    add_index :questions, :question_type
    add_index :questions, [:topic_id, :question_type]
    add_index :sources, :name
    add_index :topics, :name
    add_index :exams, :created_at
  end

  def down
    change_column_null :questions, :question_type, true
    change_column_null :exam_questions, :position, true
    change_column_null :topic_modules, :name, true
    change_column_null :topic_modules, :position, true
    change_column_null :sources, :name, true
    change_column_null :sources, :source_type, true
    change_column_null :exams, :title, true

    remove_index :questions, :question_type, if_exists: true
    remove_index :questions, [:topic_id, :question_type], if_exists: true
    remove_index :sources, :name, if_exists: true
    remove_index :topics, :name, if_exists: true
    remove_index :exams, :created_at, if_exists: true
  end
end
