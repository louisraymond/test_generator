module Topic::LearningObjectiveManagement
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_learning_objectives
  end

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
