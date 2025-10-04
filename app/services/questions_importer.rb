class QuestionsImporter
  class Error < StandardError; end
  class ValidationError < Error; end
  class ImportError < Error; end

  def self.call(data, options = {})
    new(data, options).import
  end

  def initialize(data, options = {})
    @data = data
    @dry_run = options[:dry_run] || false
    @errors = []
    @warnings = []
    @created_questions = []
    @created_topics = []
    @created_sources = []
  end

  def import
    ActiveRecord::Base.transaction do
      parse_and_validate_data
      create_questions unless @dry_run
      build_result
    end
  rescue => e
    raise Error, "Import failed: #{e.message}"
  end

  private

  def parse_and_validate_data
    @data.each_with_index do |row_data, index|
      row_number = index + 1
      
      begin
        parser = QuestionRowParser.new(row_data, row_number)
        parsed_question = parser.parse
        
        if parser.errors.any?
          @errors.concat(parser.errors.map { |error| "Row #{row_number}: #{error}" })
        else
          validator = QuestionTypeValidator.new(parsed_question)
          validator.validate
          
          if validator.errors.any?
            @errors.concat(validator.errors.map { |error| "Row #{row_number}: #{error}" })
          else
            @warnings.concat(validator.warnings.map { |warning| "Row #{row_number}: #{warning}" })
            @parsed_questions ||= []
            @parsed_questions << parsed_question
          end
        end
      rescue => e
        @errors << "Row #{row_number}: Failed to parse - #{e.message}"
      end
    end

    raise ValidationError, "Validation failed with #{@errors.count} errors" if @errors.any?
  end

  def create_questions
    @parsed_questions.each do |question_data|
      begin
        # Resolve or create topic
        topic = resolve_topic(question_data[:topic])
        
        # Resolve or create source (optional)
        source = resolve_source(question_data[:source]) if question_data[:source].present?
        
        # Create question
        question = Question.create!(
          topic: topic,
          source: source,
          source_reference: question_data[:source_reference],
          content: question_data[:content],
          answer: question_data[:answer],
          points: question_data[:points],
          answer_size: question_data[:answer_size],
          question_type: question_data[:question_type],
          answer_label: question_data[:answer_label],
          unit: question_data[:unit],
          options: question_data[:options] || []
        )
        
        @created_questions << question
      rescue => e
        @errors << "Failed to create question: #{e.message}"
        raise ImportError, "Question creation failed"
      end
    end
  end

  def resolve_topic(topic_name)
    return @created_topics.find { |t| t.name == topic_name } if @created_topics.any? { |t| t.name == topic_name }
    
    topic = Topic.find_by(name: topic_name)
    if topic
      topic
    else
      topic = Topic.create!(name: topic_name)
      @created_topics << topic
      topic
    end
  end

  def resolve_source(source_name)
    return @created_sources.find { |s| s.name == source_name } if @created_sources.any? { |s| s.name == source_name }
    
    source = Source.find_by(name: source_name)
    if source
      source
    else
      source = Source.create!(name: source_name)
      @created_sources << source
      source
    end
  end

  def build_result
    {
      success: @errors.empty?,
      errors: @errors,
      warnings: @warnings,
      created_questions: @created_questions.count,
      created_topics: @created_topics.count,
      created_sources: @created_sources.count,
      questions: @created_questions
    }
  end
end
