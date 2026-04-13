class ExamsController < ApplicationController
  def index
    @exams = Exam.includes(exam_questions: { question: :topic }).order(created_at: :desc)
  end

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
    
    # Extract font size and spacing parameters for PDF generation
    @font_size = params[:font_size]&.to_i || 14
    @question_spacing = params[:question_spacing]&.to_i || 18

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
      format.html
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

  # Lightweight JSON endpoint to preview availability and allocation
  def preview_counts
    topic_ids = Array(params[:topic_ids]).reject(&:blank?)
    types     = Array(params[:question_types]).reject(&:blank?)
    count     = params[:question_count].to_i
    weights   = (params[:topic_weights] || {}).to_h.transform_keys(&:to_s)

    scope = Question.where(topic_id: topic_ids)
    scope = scope.where(question_type: types) if types.present?

    total_available = scope.count
    per_type = scope.group(:question_type).count
    per_topic = scope.group(:topic_id).count

    allocation = {}
    if topic_ids.any? && count.positive?
      begin
        alloc = ExamBuilder.allocate_by_weights(scope, topic_ids, weights, [count, total_available].min)
        # Count how many picked per topic id
        allocation = alloc.group_by { |q| q.topic_id.to_s }.transform_values(&:size)
      rescue => _e
        allocation = {}
      end
    end

    render json: {
      total_available: total_available,
      per_type: per_type,
      per_topic: per_topic,
      suggested_allocation: allocation
    }
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
