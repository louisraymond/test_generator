class QuestionsController < ApplicationController
  before_action :set_question, only: %i[edit update]
  before_action :load_filters, only: :index
  before_action :load_form_data, only: %i[new create edit update]

  def index
    scope = Question.includes(:topic, :source, :learning_objectives)
    scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
    scope = scope.where(source_id: params[:source_id]) if params[:source_id].present?
    scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?

    @total_count = scope.count
    @type_counts = scope.group(:question_type).count
    @questions = scope.order(created_at: :desc).limit(200)
    @capped = @total_count > @questions.size
  end

  def new
    @question = Question.new(points: 1, question_type: 'written')
    @question.options_text = ''
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to questions_path, notice: 'Question created successfully.'
    else
      @question.options_text = params.dig(:question, :options_text)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @question.options_text ||= format_options(@question.options)
  end

  def update
    if @question.update(question_params)
      redirect_to questions_path, notice: 'Question updated successfully.'
    else
      @question.options_text = params.dig(:question, :options_text)
      render :edit, status: :unprocessable_entity
    end
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

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def load_filters
    @topics = Topic.order(:name)
    @sources = Source.order(:name)
  end

  def load_form_data
    @topics_for_form = Topic.includes(:learning_objectives).order(:name)
    @sources_for_form = Source.order(:name)
  end

  def question_params
    permitted = params.require(:question).permit(
      :topic_id,
      :source_id,
      :content,
      :answer,
      :points,
      :answer_size,
      :question_type,
      :source_reference,
      :answer_label,
      :unit,
      :options_text,
      learning_objective_ids: [],
      multi_choice_options: %i[text correct],
      ranking_options: %i[text rank]
    )

    permitted[:source_id] = permitted[:source_id].presence
    permitted[:learning_objective_ids] = Array(permitted[:learning_objective_ids]).reject(&:blank?)

    case permitted[:question_type]
    when 'multiple_choice'
      permitted[:options_text] = serialize_multi_choice(permitted.delete(:multi_choice_options))
      permitted.delete(:ranking_options)
    when 'ranking'
      permitted[:options_text] = serialize_ranking(permitted.delete(:ranking_options))
      permitted.delete(:multi_choice_options)
    else
      permitted.delete(:multi_choice_options)
      permitted.delete(:ranking_options)
    end

    permitted
  end

  def format_options(value)
    return '' if value.blank?

    JSON.pretty_generate(value)
  rescue JSON::GeneratorError
    value.to_s
  end

  def serialize_multi_choice(raw_options)
    return '' unless raw_options

    options_array = raw_options.to_h.sort_by { |key, _| key.to_s.to_i }.map do |_, attrs|
      text = attrs[:text].to_s.strip
      next if text.blank?

      {
        text: text,
        correct: ActiveModel::Type::Boolean.new.cast(attrs[:correct])
      }
    end.compact

    options_array.to_json
  end

  def serialize_ranking(raw_options)
    return '' unless raw_options

    options_array = raw_options.to_h.sort_by { |key, _| key.to_s.to_i }.map.with_index do |(_, attrs), idx|
      text = attrs[:text].to_s.strip
      next if text.blank?

      rank_value = attrs[:rank].to_i
      rank = rank_value.positive? ? rank_value : idx + 1

      {
        text: text,
        rank: rank
      }
    end.compact

    options_array.sort_by { |opt| opt[:rank] }.to_json
  end
end
