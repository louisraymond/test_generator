class QuestionsController < ApplicationController
  def index
    @topics = Topic.order(:name)
    @sources = Source.order(:name)

    scope = Question.includes(:topic, :source)
    scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
    scope = scope.where(source_id: params[:source_id]) if params[:source_id].present?
    scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?

    @questions = scope.order(created_at: :desc).limit(200)
  end
  def types_preview
    @random_questions = Question.order(Arel.sql('RANDOM()')).limit(15)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'questions/types_preview', layout: 'pdf', formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true,
          wait_until: 'domcontentloaded',
          timeout: 90_000
        ).to_pdf
        send_data pdf, filename: 'preview.pdf', type: 'application/pdf'
      end
    end
  end
end
