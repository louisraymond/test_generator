class QuestionsController < ApplicationController
  before_action :set_question, only: %i[edit update toggle_correct toggle_blank toggle_eliminated options_patch]
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

  # /questions/new
  #
  # Two-phase flow so the new paper-is-editor (Wave 5) can load a
  # real Question record:
  #   Phase A — no ?type=   → show the type-picker screen
  #   Phase B — ?type=<key> → create a stub Question of that type with
  #                           sensible defaults, then redirect to its
  #                           edit page where the paper-is-editor lives.
  # ?ui=classic keeps the old multi-section form alive for anyone who
  # bookmarked it.
  def new
    if params[:learning_objective_id].present?
      @learning_objective = LearningObjective.includes(:topic).find_by(id: params[:learning_objective_id])
    end

    if params[:ui] == 'classic'
      @question = Question.new(points: 1, question_type: 'written')
      @question.options_text = ''
      if @learning_objective
        @question.topic = @learning_objective.topic
        @question.learning_objective_ids = [@learning_objective.id]
      end
      render :new and return
    end

    if params[:type].present? && Question::QUESTION_TYPES.include?(params[:type])
      question = build_stub_question(params[:type], learning_objective: @learning_objective)
      if question.save
        redirect_to edit_question_path(question) and return
      else
        flash[:alert] = question.errors.full_messages.join('; ')
      end
    end

    # Type picker (Phase A).
    @question_types = QuestionTypes.all
    render :new_picker
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to edit_question_path(@question), notice: 'Question created.'
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
      respond_to do |format|
        format.html { redirect_to questions_path, notice: 'Question updated successfully.' }
        format.json { head :ok }
      end
    else
      @question.options_text = params.dig(:question, :options_text)
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity }
      end
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
    already_correct = ActiveModel::Type::Boolean.new.cast(options.dig(idx, 'correct'))
    options.each_with_index do |opt, i|
      # Single-correct MCQ: flip all others off. If the clicked option
      # was already the correct one, toggle it off so the author can
      # return to an unmarked state.
      opt['correct'] = (i == idx) && !already_correct
    end
    # Bypass the MCQ validator — it coerces options through a `||` chain
    # that nils-out explicit `false` values. The shape we wrote is already
    # valid on re-read (one true, rest false).
    @question.update_columns(options: options, updated_at: Time.current)
    head :ok
  end

  # Wave 3 — MCQ shift-click toggles the `eliminated` flag so the printed
  # paper (and the rail preview) can visually strike options the author has
  # discarded as distractors — kept for history but won't be credited.
  def toggle_eliminated
    unless @question.question_type == 'multiple_choice'
      head :unprocessable_entity and return
    end

    idx = params[:index].to_i
    options = @question.options.map(&:deep_dup)
    return head(:unprocessable_entity) if idx.negative? || idx >= options.length

    current = ActiveModel::Type::Boolean.new.cast(options[idx]['eliminated'])
    options[idx]['eliminated'] = !current
    @question.update_columns(options: options, updated_at: Time.current)
    head :ok
  end

  def destroy
    question = Question.find_by(id: params[:id])
    if question.nil?
      respond_to do |format|
        format.html { redirect_to questions_path, alert: "Question not found." }
        format.json { render json: { error: "Question #{params[:id]} not found" }, status: :not_found }
      end
      return
    end

    question.destroy!
    respond_to do |format|
      format.html { redirect_to questions_path, notice: "Question deleted." }
      format.json { head :no_content }
    end
  end

  # Wave 3 — generic per-type options patcher. Stimulus controllers PATCH
  # here with either:
  #   { options: {key: value, ...} } — straight merge into jsonb (matching,
  #     simple add/remove)
  #   { options: {add_pin: {...}} }  — type-specific command keys handled
  #     below (pin drops, mask draws, reorder, line highlight, part add).
  def options_patch
    patch = params[:options].permit!.to_h if params[:options].respond_to?(:permit!)
    patch ||= params[:options].to_unsafe_h if params[:options].respond_to?(:to_unsafe_h)
    patch ||= params[:options]
    return head(:unprocessable_entity) unless patch.is_a?(Hash)
    patch = patch.deep_stringify_keys

    current = if @question.options.is_a?(Hash)
                @question.options.deep_dup
              elsif @question.options.is_a?(Array)
                { 'items' => @question.options.deep_dup }
              else
                {}
              end

    patch.each do |key, value|
      case key
      when 'add_pin'
        current['pins'] ||= []
        current['pins'] << { 'x' => value['x'], 'y' => value['y'], 'answer' => '' }
      when 'remove_pin'
        current['pins'] ||= []
        current['pins'].delete_at(value.to_i) if value.to_i.between?(0, current['pins'].length - 1)
      when 'add_mask'
        current['masks'] ||= []
        current['masks'] << { 'x' => value['x'], 'y' => value['y'],
                              'w' => value['w'], 'h' => value['h'],
                              'answer' => '', 'shape' => 'rect' }
      when 'remove_mask'
        current['masks'] ||= []
        current['masks'].delete_at(value.to_i) if value.to_i.between?(0, current['masks'].length - 1)
      when 'reorder'
        arr = @question.options.is_a?(Array) ? @question.options.deep_dup : Array(current['items'])
        from, to = value['from'].to_i, value['to'].to_i
        if arr[from] && arr[to] && from != to
          item = arr.delete_at(from)
          arr.insert(to, item)
        end
        @question.update_columns(options: arr, updated_at: Time.current)
        head :ok and return
      when 'toggle_highlighted_line'
        current['highlighted_lines'] ||= []
        if current['highlighted_lines'].include?(value.to_i)
          current['highlighted_lines'].delete(value.to_i)
        else
          current['highlighted_lines'] << value.to_i
        end
      when 'update_part'
        return head(:unprocessable_entity) unless @question.question_type == 'composite'

        # Editor #11 — AR rows are the new source of truth. Composites
        # backfilled by migration 20260428060647 (or new ones created
        # post-deploy) take the AR path; pre-migration fixtures and any
        # composite still living entirely in jsonb fall through to the
        # legacy path for one deprecation cycle.
        if @question.question_parts.any?
          idx = value['index'].to_i
          return head(:unprocessable_entity) if idx.negative?

          part = @question.question_parts.find_by(position: idx + 1)
          return head(:unprocessable_entity) unless part

          # Whitelist the same attributes the legacy jsonb path accepted.
          # The wire shape uses `type` (jsonb era) but AR uses `part_type`;
          # accept either for backward compat with in-flight clients.
          attrs = {}
          attrs[:stem]         = value['stem']         if value.key?('stem')
          attrs[:part_type]    = value['part_type']    if value.key?('part_type')
          attrs[:part_type]    = value['type']         if value.key?('type') && !attrs.key?(:part_type)
          attrs[:marks]        = value['marks'].to_i   if value.key?('marks')
          attrs[:answer_label] = value['answer_label'] if value.key?('answer_label')
          attrs[:unit]         = value['unit']         if value.key?('unit')
          # `answer_size` lives on the QuestionPart#options jsonb (it isn't
          # promoted to a column yet) — merge in place so we don't clobber
          # other typed-options keys.
          if value.key?('answer_size')
            merged_options = (part.options.is_a?(Hash) ? part.options : {}).merge('answer_size' => value['answer_size'])
            attrs[:options] = merged_options
          end

          part.update!(attrs)
        else
          parts = Array(current['parts'])
          idx   = value['index'].to_i
          return head(:unprocessable_entity) if idx.negative? || idx >= parts.length

          updated = parts[idx].dup
          %w[stem type marks answer_label answer_size unit].each do |attr|
            updated[attr] = value[attr] if value.key?(attr)
          end
          parts[idx] = updated
          current['parts'] = parts
        end
      when 'add_part'
        return head(:unprocessable_entity) unless @question.question_type == 'composite'

        if @question.question_parts.any?
          after_index = value['after'].to_i
          insert_position = after_index + 2 # 1-based position of the new part

          ActiveRecord::Base.transaction do
            # Shift subsequent parts (positions >= insert_position) by +1
            # to make room. Update the highest position first so we never
            # collide on the (question_id, parent_part_id, position) tuple
            # mid-flight.
            @question.question_parts
                     .where('position >= ?', insert_position)
                     .order(position: :desc)
                     .each { |p| p.update!(position: p.position + 1) }

            @question.question_parts.create!(
              position:  insert_position,
              stem:      '',
              part_type: 'written',
              marks:     1,
              options:   { 'answer_size' => 'medium' }
            )
          end
        else
          parts = Array(current['parts']).map(&:deep_dup)
          after = value['after'].to_i
          insert_at = (after + 1).clamp(0, parts.length)

          new_part = {
            'stem'        => '',
            'type'        => 'written',
            'marks'       => 1,
            'answer_size' => 'medium',
          }
          parts.insert(insert_at, new_part)
          current['parts'] = parts
        end
      else
        current[key] = value
      end
    end

    @question.update_columns(options: current, updated_at: Time.current)

    respond_to do |format|
      format.json { head :ok }
      format.html { render partial: 'questions/cm_composite', locals: { question: @question.reload } }
    end
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

  # Wave 5 — stub Question used by the type-picker flow. We have to
  # satisfy presence/points/answer validations on save but don't want
  # to prompt for them up-front — the paper-is-editor fills them in
  # interactively. Defaults are deliberately neutral so nothing about
  # the seeded stub leaks into the real content.
  def build_stub_question(type, learning_objective: nil)
    topic = learning_objective&.topic || Topic.order(:name).first
    q = Question.new(
      question_type: type,
      topic: topic,
      content: default_stub_content(type),
      answer: 'Model answer — edit in the rail.',
      points: default_stub_points(type),
      options: default_stub_options(type)
    )
    q.learning_objective_ids = [learning_objective.id] if learning_objective
    q
  end

  def default_stub_content(_type)
    'New question. Click to edit.'
  end

  def default_stub_points(type)
    case type
    when 'multiple_choice', 'cloze' then 1
    when 'ranking', 'ordering', 'matching' then 3
    when 'composite' then 6
    else 2
    end
  end

  def default_stub_options(type)
    case type
    when 'multiple_choice' then [
      { 'text' => 'Option A', 'correct' => true },
      { 'text' => 'Option B', 'correct' => false }
    ]
    when 'matching' then { 'left' => %w[A B], 'right' => %w[1 2] }
    when 'ordering' then [{ 'text' => 'First' }, { 'text' => 'Second' }]
    when 'ranking' then [
      { 'text' => 'First',  'rank' => 1 },
      { 'text' => 'Second', 'rank' => 2 }
    ]
    when 'code_analysis' then {
      'language' => 'python',
      'code' => "# click to edit\nprint('hello')",
      'answer_format' => 'lines'
    }
    when 'diagram_label'   then { 'image' => '', 'pins' => [] }
    when 'image_occlusion' then { 'image' => '', 'masks' => [] }
    when 'cloze'           then { 'tokens' => [] }
    else []
    end
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
