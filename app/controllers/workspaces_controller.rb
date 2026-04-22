# frozen_string_literal: true

# Single-controller shell for the redesign's four-tab workspace:
#   /workspace?tab=setup|kb|canvas|review
#
# Intentionally thin: each tab's content lives in a partial under
# app/views/workspaces/. Phase 3 ships stub partials — Phases 4-9 replace
# them with the real screens.
class WorkspacesController < ApplicationController
  layout 'workspace'

  TABS = %w[setup kb canvas review].freeze
  DEFAULT_TAB = 'setup'

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
  end

  # Placeholder — Phase 4 uses it for the Setup form. Keeps the route alive
  # so the spec suite can assert POST targets exist before partials wire up.
  def update
    head :no_content
  end
end
