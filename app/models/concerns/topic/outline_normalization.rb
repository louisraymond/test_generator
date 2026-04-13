module Topic::OutlineNormalization
  extend ActiveSupport::Concern

  included do
    validate :outline_shapes
    validate :parent_topic_must_be_root
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
end
