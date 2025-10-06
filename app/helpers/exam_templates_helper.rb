module ExamTemplatesHelper
  def build_source_options(topics, source_type, selected_id = nil)
    case source_type
    when 'Topic'
      options_from_collection_for_select(topics || [], :id, :name, selected_id)
    when 'TopicModule'
      modules = TopicModule.includes(:topic).order('topics.name, topic_modules.name')
      options_from_collection_for_select(modules, :id, ->(m) { "#{m.topic.name} → #{m.name}" }, selected_id)
    when 'LearningObjective'
      los = LearningObjective.includes(topic_module: :topic).order('topics.name, topic_modules.name, learning_objectives.category')
      options_from_collection_for_select(los, :id, ->(lo) { "#{lo.topic_module.topic.name} → #{lo.topic_module.name} → #{lo.description.truncate(50)}" }, selected_id)
    when '', nil
      # Default: show all topics when no type selected
      options_from_collection_for_select(topics || [], :id, :name, selected_id)
    else
      []
    end
  end
  
  def group_questions_by_topic(questions)
    questions.group_by { |q| q.topic.name }.map do |topic_name, qs|
      [topic_name, qs.map { |q| ["Q#{q.id}: #{q.question_type} - #{q.question_stem&.truncate(50) || 'No stem'}", q.id] }]
    end
  end
end

