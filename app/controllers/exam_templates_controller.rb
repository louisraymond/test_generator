class ExamTemplatesController < ApplicationController
  before_action :set_exam_template, only: [:show, :edit, :update, :destroy, :generate]

  def index
    @exam_templates = ExamTemplate.includes(:exam_sections)
                                   .order(created_at: :desc)
    
    @recently_used = ExamTemplate.recently_used.limit(5)
    @most_used = ExamTemplate.most_used.limit(5)
  end

  def show
    @exam_template = ExamTemplate.includes(exam_sections: [:section_source_rules, :section_question_rules]).find(params[:id])
  end

  def new
    @exam_template = ExamTemplate.new
    @exam_template.exam_sections.build(position: 0)
    load_form_data
  end

  def create
    @exam_template = ExamTemplate.new(exam_template_params)

    if @exam_template.save
      redirect_to @exam_template, notice: 'Exam template created successfully.'
    else
      load_form_data
      render :new
    end
  end

  def edit
    load_form_data
  end

  def update
    if @exam_template.update(exam_template_params)
      redirect_to @exam_template, notice: 'Exam template updated successfully.'
    else
      load_form_data
      render :edit
    end
  end

  def destroy
    @exam_template.destroy
    redirect_to exam_templates_path, notice: 'Exam template deleted successfully.'
  end
  
  # Generate an exam from this template
  def generate
    exam = ExamBuilder.from_template(template_id: @exam_template.id)
    redirect_to exam_path(exam), notice: "Exam generated from template: #{@exam_template.name}"
  rescue ExamBuilder::Error => e
    redirect_to @exam_template, alert: "Failed to generate exam: #{e.message}"
  end

  private

  def set_exam_template
    @exam_template = ExamTemplate.find(params[:id])
  end

  def exam_template_params
    params.require(:exam_template).permit(
      :name,
      :description,
      :duration_minutes,
      exam_sections_attributes: [
        :id,
        :name,
        :position,
        :question_count,
        :duration_minutes,
        :min_points,
        :max_points,
        :_destroy,
        question_type_filter: [],
        section_source_rules_attributes: [
          :id,
          :source_type,
          :source_id,
          :weight,
          :question_count_override,
          :_destroy
        ],
        section_question_rules_attributes: [
          :id,
          :question_id,
          :rule_type,
          :repeat_count,
          :_destroy
        ]
      ]
    )
  end
  
  def load_form_data
    @topics = Topic.includes(:topic_modules, :learning_objectives).order(:name)
    @questions = Question.includes(:topic).order('topics.name, questions.id')
    @question_types = Question.distinct.pluck(:question_type).compact.sort
    
    # Prepare JSON data for JavaScript
    @topics_json = @topics.map { |t| { id: t.id, name: t.name } }.to_json
    
    @modules_json = TopicModule.includes(:topic).order('topics.name, topic_modules.name').map do |m|
      { id: m.id, name: m.name, topic_name: m.topic.name }
    end.to_json
    
    @learning_objectives_json = LearningObjective.includes(topic_module: :topic)
      .where.not(topic_module_id: nil)
      .order('topics.name, topic_modules.name, learning_objectives.category').map do |lo|
        next unless lo.topic_module && lo.topic_module.topic
        { 
          id: lo.id, 
          description: lo.description,
          module_path: "#{lo.topic_module.topic.name} → #{lo.topic_module.name}"
        }
      end.compact.to_json
  end
end

