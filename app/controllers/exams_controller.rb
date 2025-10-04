class ExamsController < ApplicationController
  def new
    @topics = Topic.order(:name)
    @question_types = Question::QUESTION_TYPES
    @sources = Source.order(:name)
  end

  def create
    p = exam_params

    title     = p[:title].presence || 'Practice Exam'
    topic_ids = Array(p[:topic_ids]).reject(&:blank?)
    count     = p[:question_count].to_i

    # Sanitize optional filters
    types = Array(p[:question_types]).reject(&:blank?)
    types &= Question::QUESTION_TYPES

    # Keep only weights for selected topics; cast to float and drop blanks/zeros
    raw_weights_params = p[:topic_weights]
    raw_weights = raw_weights_params.is_a?(ActionController::Parameters) ? raw_weights_params.to_h : (raw_weights_params || {})
    weights = raw_weights
              .slice(*topic_ids.map(&:to_s))
              .transform_values { |v| v.to_s.strip }
              .reject { |_k, v| v.blank? || v.to_f <= 0 }
              .transform_values(&:to_f)

    duration = p[:duration_minutes].presence&.to_i
    allow_repeats = ActiveModel::Type::Boolean.new.cast(p[:allow_repeats])

    @exam = ExamBuilder.call(
      topic_ids: topic_ids,
      count: count,
      title: title,
      strict: true,
      types: types.presence,
      topic_weights: weights.presence,
      duration_minutes: duration,
      allow_repeats: allow_repeats
    )

    redirect_to exam_path(@exam)
  rescue ExamBuilder::Error => e
    flash.now[:alert] = e.message
    @topics = Topic.order(:name)
    @question_types = Question::QUESTION_TYPES
    @sources = Source.order(:name)
    render :new, status: :unprocessable_entity
  end

  def show
    @exam = Exam.includes(exam_questions: :question).find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'exams/show', layout: 'pdf', formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true,
          wait_until: 'domcontentloaded',
          timeout: 90_000
        ).to_pdf
        send_data pdf, filename: "exam_#{@exam.id}.pdf", type: 'application/pdf'
      end
    end
  end

  def marking_scheme
    @exam = Exam.includes(exam_questions: :question).find(params[:id])

    respond_to do |format|
      format.pdf do
        html = render_to_string(template: 'exams/marking_scheme', layout: false, formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true,
          wait_until: 'domcontentloaded',
          timeout: 90_000
        ).to_pdf
        send_data pdf, filename: "marking_scheme_#{@exam.id}.pdf", type: 'application/pdf'
      end
    end
  end

  private

  def exam_params
    params.permit(
      :title,
      :question_count,
      :duration_minutes,
      :allow_repeats,
      topic_ids: [],
      question_types: [],
      topic_weights: {}
    )
  end
end
