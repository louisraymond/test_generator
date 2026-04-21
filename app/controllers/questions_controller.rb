class QuestionsController < ApplicationController
  before_action :set_question, only: %i[edit update toggle_correct toggle_blank]
  before_action :load_filters, only: :index
  before_action :load_form_data, only: %i[new create edit update]

  def index
    scope = Question.includes(:topic, :source, :learning_objectives)
    scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
    scope = scope.where(source_id: params[:source_id]) if params[:source_id].present?
    scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?

    @total_count = scope.count
    @type_counts = scope.group(:question_type).count
    @pagy, @questions = pagy(scope.order(created_at: :desc), items: 50)
  end

  def new
    @question = Question.new(points: 1, question_type: 'written')
    @question.options_text = ''
    
    # Pre-populate from learning objective if provided
    if params[:learning_objective_id].present?
      @learning_objective = LearningObjective.includes(:topic).find_by(id: params[:learning_objective_id])
      if @learning_objective
        @question.topic = @learning_objective.topic
        @question.learning_objective_ids = [@learning_objective.id]
      end
    end
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

  # Phase 7 — MCQ paper-is-editor: click an option on the paper to mark it
  # correct. Single-choice semantics (flips others off). Non-MCQ questions
  # return 422 so the Stimulus controller can ignore stale clicks.
  def toggle_correct
    unless @question.question_type == 'multiple_choice'
      head :unprocessable_entity and return
    end

    idx = params[:index].to_i
    options = @question.options.map(&:deep_dup)
    options.each_with_index do |opt, i|
      opt['correct'] = (i == idx)
    end
    # Bypass the MCQ validator — it coerces options through a `||` chain
    # that nils-out explicit `false` values. The shape we wrote is already
    # valid on re-read (one true, rest false).
    @question.update_columns(options: options, updated_at: Time.current)
    head :ok
  end

  # Phase 7 — Cloze paper-is-editor: click a word to blank it. Stores a
  # `tokens` array under options with {index, blanked, word, answer} entries
  # so the renderer can draw the printed gaps deterministically.
  def toggle_blank
    unless @question.question_type == 'cloze'
      head :unprocessable_entity and return
    end

    words = @question.content.to_s.split(/\s+/)
    idx = params[:word_index].to_i
    return head(:unprocessable_entity) if idx.negative? || idx >= words.length

    tokens = Array(@question.options.is_a?(Hash) ? @question.options['tokens'] : []).map(&:deep_dup)
    existing = tokens.index { |t| t.is_a?(Hash) && t['index'] == idx }

    if existing
      tokens.delete_at(existing)
    else
      tokens << { 'index' => idx, 'blanked' => true, 'word' => words[idx] }
    end

    payload = (@question.options.is_a?(Hash) ? @question.options : {}).merge('tokens' => tokens)
    @question.update!(options: payload)
    head :ok
  end

  def types_preview
    @random_questions = Question.order(Arel.sql('RANDOM()')).limit(15)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'questions/types_preview', layout: 'pdf', formats: [:html])
        pdf = PdfRenderer.render_to_pdf(html: html, base_url: request.base_url)
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
      :bloom_level,
      :question_type,
      :source_reference,
      :answer_label,
      :unit,
      :options_text,
      learning_objective_ids: [],
      multi_choice_options: %i[text correct],
      ranking_options: %i[text rank],
      code_analysis: [
        :language, :code, :answer_format,
        { choices: %i[text correct] }
      ]
    )

    permitted[:source_id] = permitted[:source_id].presence
    permitted[:answer_size] = permitted[:answer_size].presence
    permitted[:bloom_level] = permitted[:bloom_level].presence
    permitted[:learning_objective_ids] = Array(permitted[:learning_objective_ids]).reject(&:blank?)

    case permitted[:question_type]
    when 'multiple_choice'
      permitted[:options_text] = serialize_multi_choice(permitted.delete(:multi_choice_options))
      permitted.delete(:ranking_options)
      permitted.delete(:code_analysis)
    when 'ranking'
      permitted[:options_text] = serialize_ranking(permitted.delete(:ranking_options))
      permitted.delete(:multi_choice_options)
      permitted.delete(:code_analysis)
    when 'code_analysis'
      permitted[:options_text] = serialize_code_analysis(permitted.delete(:code_analysis))
      permitted.delete(:multi_choice_options)
      permitted.delete(:ranking_options)
    else
      permitted.delete(:multi_choice_options)
      permitted.delete(:ranking_options)
      permitted.delete(:code_analysis)
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

  def serialize_code_analysis(raw)
    return '' if raw.blank?

    data = {
      'language'      => raw[:language].to_s,
      'code'          => raw[:code].to_s,
      'answer_format' => raw[:answer_format].to_s
    }

    if raw[:answer_format] == 'multiple_choice'
      choices_raw = raw[:choices]
      choices_enum = choices_raw.respond_to?(:values) ? choices_raw.values : Array(choices_raw)
      data['choices'] = choices_enum.map do |c|
        text = c[:text].to_s
        next if text.strip.empty?
        { 'text' => text, 'correct' => ActiveModel::Type::Boolean.new.cast(c[:correct]) }
      end.compact
    end

    data.to_json
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
