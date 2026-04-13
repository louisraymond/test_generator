class ExamSection < ApplicationRecord
  belongs_to :exam_template
  has_many :section_source_rules, dependent: :destroy
  has_many :section_question_rules, dependent: :destroy
  
  # Polymorphic associations through source rules
  has_many :topics, through: :section_source_rules, source: :source, source_type: 'Topic'
  has_many :topic_modules, through: :section_source_rules, source: :source, source_type: 'TopicModule'
  has_many :learning_objectives, through: :section_source_rules, source: :source, source_type: 'LearningObjective'
  
  # Force-included questions
  has_many :forced_questions, -> { where(rule_type: 'force_include') }, 
           through: :section_question_rules, source: :question
  
  # Excluded questions
  has_many :excluded_questions, -> { where(rule_type: 'exclude') }, 
           through: :section_question_rules, source: :question
  
  accepts_nested_attributes_for :section_source_rules, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :section_question_rules, allow_destroy: true, reject_if: :all_blank
  
  validates :name, presence: true
  validates :question_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Question type filter is stored as jsonb array
  def question_types
    (question_type_filter || []).reject(&:blank?)
  end
  
  def question_types=(types)
    self.question_type_filter = types.reject(&:blank?)
  end
  
  def allows_question_type?(type)
    question_types.empty? || question_types.include?(type.to_s)
  end
  
  # Get all available questions for this section based on rules
  def available_questions
    return Question.none if section_source_rules.empty?
    
    # Collect question IDs from all source rules
    question_ids = Set.new
    
    # Group source rules by type and batch-query each type once (max 3 queries)
    rules_by_type = section_source_rules.group_by(&:source_type)

    topic_ids = rules_by_type.fetch('Topic', []).map(&:source_id)
    module_ids = rules_by_type.fetch('TopicModule', []).map(&:source_id)
    lo_ids = rules_by_type.fetch('LearningObjective', []).map(&:source_id)

    question_ids.merge(Question.where(topic_id: topic_ids).pluck(:id)) if topic_ids.any?
    question_ids.merge(Question.where(topic_module_id: module_ids).pluck(:id)) if module_ids.any?
    if lo_ids.any?
      question_ids.merge(
        Question.joins(:question_learning_objectives)
                .where(question_learning_objectives: { learning_objective_id: lo_ids })
                .pluck(:id)
      )
    end
    
    # Start with all questions from source rules
    questions = Question.where(id: question_ids.to_a)
    
    # Filter by question types if specified
    questions = questions.where(question_type: question_types) if question_types.any?
    
    # Exclude blacklisted questions
    excluded_ids = section_question_rules.where(rule_type: 'exclude').pluck(:question_id)
    questions = questions.where.not(id: excluded_ids) if excluded_ids.any?
    
    questions.distinct
  end
end

