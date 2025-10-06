class Topic < ApplicationRecord
  attribute :module_aims, :json, default: []
  attribute :learning_outcomes, :json, default: []
  attribute :syllabus_outline, :json, default: []
  attribute :reference_links, :json, default: []

  belongs_to :parent_topic, class_name: 'Topic', optional: true
  has_many :subtopics, class_name: 'Topic', foreign_key: :parent_topic_id, dependent: :nullify

  has_many :topic_modules, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :learning_objectives, -> { order(:category_order, :position, :id) }, dependent: :destroy

  accepts_nested_attributes_for :learning_objectives, allow_destroy: true
  accepts_nested_attributes_for :topic_modules, allow_destroy: true

  validates :name, presence: true
  validate :outline_shapes
  validate :parent_topic_must_be_root

  before_validation :normalize_learning_objectives

  def module_aim_list
    module_aims.is_a?(Array) ? module_aims.compact_blank : []
  end

  def learning_outcome_sections
    groups = learning_objective_groups(include_counts: false)
    return groups if groups.present?

    normalize_sections(learning_outcomes)
  end

  def syllabus_sections
    normalize_sections(syllabus_outline)
  end

  def reference_tokens
    reference_links.is_a?(Array) ? reference_links.compact_blank : []
  end

  def learning_outcome_sections_with_counts
    groups = learning_objective_groups(include_counts: true)
    return attach_zero_counts_to_sections(learning_outcome_sections) if groups.empty?

    groups
  end

  def question_total_count
    if association(:questions).loaded?
      questions.size
    else
      questions.count
    end
  end

  private

  def normalize_sections(value)
    return [] unless value.is_a?(Array)

    value.filter_map do |section|
      next unless section.is_a?(Hash)

      title = section['title'] || section[:title]
      items = section['items'] || section[:items]

      next unless title.is_a?(String) && title.present?
      next unless items.is_a?(Array)

      normalized_items = items.filter_map do |item|
        item if item.is_a?(String) && item.present?
      end

      next if normalized_items.empty?

      { 'title' => title, 'items' => normalized_items }
    end
  end

  def outline_shapes
    unless array_of_strings?(module_aims)
      errors.add(:module_aims, 'must be an array of strings')
    end

    unless sections_with_items?(learning_outcomes)
      errors.add(:learning_outcomes, 'must be an array of sections with outcomes')
    end

    unless sections_with_items?(syllabus_outline)
      errors.add(:syllabus_outline, 'must be an array of sections with entries')
    end

    unless array_of_strings?(reference_links)
      errors.add(:reference_links, 'must be an array of strings')
    end
  end

  def array_of_strings?(value)
    value.is_a?(Array) && value.all? { |item| item.is_a?(String) && item.present? }
  end

  def sections_with_items?(value)
    value.is_a?(Array) && value.all? do |section|
      next false unless section.is_a?(Hash)

      title = section['title'] || section[:title]
      items = section['items'] || section[:items]

      title.is_a?(String) && title.present? &&
        items.is_a?(Array) && items.all? do |item|
          if item.is_a?(Hash)
            text = item['text'] || item[:text]
            text.is_a?(String) && text.present?
          else
            item.is_a?(String) && item.present?
          end
        end
    end
  end

  def parent_topic_must_be_root
    return if parent_topic_id.blank? || parent_topic&.parent_topic_id.blank?

    errors.add(:parent_topic_id, 'cannot reference a subtopic as a parent')
  end

  public

  def replace_learning_objectives!(sections)
    sections = Array(sections)

    Topic.transaction do
      learning_objectives.destroy_all

      sections.each_with_index do |section, section_index|
        title = section['title'] || section[:title]
        items = Array(section['items'] || section[:items])
        next if title.blank? || items.empty?

        items.each_with_index do |item, objective_index|
          text = item.is_a?(Hash) ? item['text'] || item[:text] : item
          next if text.blank?

          learning_objectives.create!(
            category: title,
            category_order: section_index,
            position: objective_index,
            description: text
          )
        end
      end

      reload
      update_columns(learning_outcomes: learning_objective_groups(include_counts: false))
    end
  end

  private

  def learning_objective_groups(include_counts: false)
    objectives = if include_counts
                   if learning_objectives.loaded?
                     learning_objectives
                   else
                     learning_objectives.includes(:questions)
                   end
                 elsif learning_objectives.loaded?
                   learning_objectives.reject(&:marked_for_destruction?)
                 else
                   learning_objectives.to_a
                 end

    objectives = objectives.to_a
    return [] if objectives.empty?

    grouped = objectives.group_by(&:category)
    grouped.sort_by { |category, objs| (objs.first.category_order || 0) }.map do |category, objs|
      items = objs.sort_by { |obj| [obj.position || 0, obj.id || 0] }.map do |obj|
        include_counts ? { 'text' => obj.description, 'count' => obj.questions.size } : obj.description
      end

      { 'title' => category, 'items' => items }
    end
  end

  def attach_zero_counts_to_sections(sections)
    sections.map do |section|
      items = section['items'].map { |text| { 'text' => text, 'count' => 0 } }
      section.merge('items' => items)
    end
  end

  def normalize_learning_objectives
    association = association(:learning_objectives)
    objectives = if association.loaded?
                   learning_objectives.target
                 else
                   learning_objectives.target.presence
                 end

    return if objectives.blank?

    objectives.each do |obj|
      obj.category = obj.category.to_s.strip
      obj.description = obj.description.to_s.strip
      if obj.category.blank? && obj.description.blank?
        obj.mark_for_destruction
      end
    end

    objectives = objectives.reject(&:marked_for_destruction?)
    if objectives.empty?
      self.learning_outcomes = []
      return
    end

    categories = []
    objectives.each do |obj|
      categories << obj.category unless categories.include?(obj.category)
    end

    categories.each_with_index do |category, cat_index|
      objectives.select { |obj| obj.category == category }.each_with_index do |obj, pos|
        obj.category_order = cat_index
        obj.position = pos
      end
    end

    self.learning_outcomes = categories.map do |category|
      items = objectives.select { |obj| obj.category == category }.map(&:description)
      { 'title' => category, 'items' => items }
    end
  end
end
