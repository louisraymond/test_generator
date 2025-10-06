class TopicsController < ApplicationController
  before_action :set_topic, only: %i[show edit update]

  def index
    @topics = Topic.where(parent_topic_id: nil).includes(:questions, :subtopics).order(:name)
  end

  def show; end

  def new
    @topic = Topic.new
    prepare_form_options
  end

  def create
    @topic = Topic.new(topic_params)

    if @topic.save
      redirect_to @topic, notice: 'Topic created successfully.'
    else
      prepare_form_options
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_form_options
  end

  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: 'Topic updated successfully.'
    else
      prepare_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_topic
    scope = Topic.all
    if action_name == 'show'
      scope = scope.includes(
        :subtopics,
        { topic_modules: { learning_objectives: :questions } },
        { learning_objectives: :questions },
        :questions
      )
    end
    @topic = scope.find(params[:id])
  end

  def prepare_form_options
    scope = Topic.where(parent_topic_id: nil).order(:name)
    scope = scope.where.not(id: @topic.id) if @topic&.persisted?
    @parent_topics = scope

    objectives_assoc = @topic.learning_objectives
    if objectives_assoc.loaded?
      return if objectives_assoc.any?
    elsif objectives_assoc.exists?
      return
    end

    if @topic.learning_outcomes.present?
      @topic.learning_outcome_sections.each_with_index do |section, section_index|
        Array(section['items']).each_with_index do |text, objective_index|
          next if text.blank?

          @topic.learning_objectives.build(
            category: section['title'],
            category_order: section_index,
            position: objective_index,
            description: text
          )
        end
      end
    end

    @topic.learning_objectives.build if @topic.learning_objectives.empty?
  end

  def topic_params
    raw = params.require(:topic).permit(
      :name,
      :epigraph_quote,
      :epigraph_attribution,
      :parent_topic_id,
      :module_aims_text,
      :syllabus_outline_text,
      :reference_links_text,
      learning_objectives_attributes: %i[id category description _destroy],
      topic_modules_attributes: %i[id name description _destroy]
    )

    result = {
      name: raw[:name],
      epigraph_quote: raw[:epigraph_quote],
      epigraph_attribution: raw[:epigraph_attribution],
      parent_topic_id: raw[:parent_topic_id].presence,
      module_aims: parse_list(raw[:module_aims_text]),
      syllabus_outline: parse_sections(raw[:syllabus_outline_text]),
      reference_links: parse_list(raw[:reference_links_text])
    }
    
    # Only include learning_objectives_attributes if present
    if raw[:learning_objectives_attributes].present?
      result[:learning_objectives_attributes] = raw[:learning_objectives_attributes]
    end
    
    # Only include topic_modules_attributes if present
    if raw[:topic_modules_attributes].present?
      result[:topic_modules_attributes] = raw[:topic_modules_attributes]
    end
    
    result
  end

  def parse_list(text)
    text.to_s.lines.map { |line| line.strip.presence }.compact
  end

  def parse_sections(text)
    sections = []
    current_title = nil
    current_items = []

    text.to_s.lines.each do |line|
      stripped = line.strip
      next if stripped.blank?

      if stripped.start_with?('-', '*')
        item = stripped.sub(/^[-*]+/, '').strip
        current_items << item unless item.blank?
      else
        if current_title.present?
          sections << { 'title' => current_title, 'items' => current_items }
        end
        current_title = stripped
        current_items = []
      end
    end

    if current_title.present?
      sections << { 'title' => current_title, 'items' => current_items }
    end

    sections
  end
end
