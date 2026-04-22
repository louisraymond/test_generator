# frozen_string_literal: true

# Single-controller shell for the redesign's five-tab workspace:
#   /workspace?tab=dashboard|setup|kb|canvas|review
#
# Dashboard is the default landing (Phase 12); Setup, Knowledge base,
# Canvas, and Review followed in earlier phases. Each tab's content
# lives in a partial under app/views/workspaces/.
class WorkspacesController < ApplicationController
  layout 'workspace'

  TABS = %w[
    dashboard
    topics questions
    templates generate
    history
    setup kb canvas review
  ].freeze
  DEFAULT_TAB = 'dashboard'

  def show
    @tab = params[:tab].presence_in(TABS) || DEFAULT_TAB
    @exam = Exam.find_by(id: params[:exam]) if params[:exam].present?
    @recent_exams = Exam.order(created_at: :desc).limit(10)

    if @tab == 'setup'
      @exam_template = ExamTemplate.new(tier: 'higher')
      @exam_template.exam_sections.build(position: 0, letter: 'A')
    end

    if @tab == 'kb'
      @topics = Topic.includes(:topic_modules, :questions).order(:name)
      @question_counts = Question.group(:topic_id).count
      @selected_topic = Topic.find_by(id: params[:topic]) if params[:topic].present?
      @topic_questions = @selected_topic&.questions&.order(:question_type, :id) || []
    end

    if @tab == 'history'
      @pagy, @history_exams = pagy(
        Exam.includes(exam_questions: { question: :topic }).order(created_at: :desc),
        items: 30
      )
    end

    if @tab == 'templates'
      @templates = ExamTemplate.includes(:exam_sections).order(created_at: :desc)
    end

    if @tab == 'questions'
      scope = Question.includes(:topic, :source)
      scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
      scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?
      @pagy, @questions = pagy(scope.order(created_at: :desc), items: 50)
      @topics_for_filter = Topic.order(:name)
      @question_type_counts = Question.group(:question_type).count
    end

    if @tab == 'topics'
      @topics = Topic.includes(:topic_modules, :questions, :learning_objectives).order(:name)
      @question_counts = Question.group(:topic_id).count
    end
  end

  # Placeholder — Phase 4 uses it for the Setup form. Keeps the route alive
  # so the spec suite can assert POST targets exist before partials wire up.
  def update
    head :no_content
  end
end
