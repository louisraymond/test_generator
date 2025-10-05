module TopicsHelper
  def outline_text_to_html(text)
    escaped = ERB::Util.html_escape(text.to_s)

    replaced = escaped.gsub(/\[\[(.+?)\]\]/) do
      raw = Regexp.last_match(1).to_s
      target, label = raw.split('|', 2).map { |part| part&.strip }
      target ||= ''
      label = label.presence || target
      next ERB::Util.html_escape(raw) if target.blank?

      slug = target.parameterize
      content_tag(
        :span,
        ERB::Util.html_escape(label),
        class: 'topic-reference',
        data: { reference: slug, target: target }
      )
    end

    replaced.html_safe
  end

  def outline_section(title, items, show_counts: false)
    content_tag(:section, class: 'topic-section') do
      concat content_tag(:h3, title)
      concat(content_tag(:ul) do
        safe_join(items.map { |item| outline_list_item(item, show_counts:) })
      end)
    end
  end

  def list_to_text(list)
    Array(list).join("\n")
  end

  def sections_to_text(sections)
    Array(sections).map do |section|
      title = section['title'] || section[:title]
      items = Array(section['items'] || section[:items])
      ([title].compact + items.map { |item| "- #{outcome_item_text(item)}" }).join("\n")
    end.join("\n\n")
  end

  private

  def outcome_item_text(item)
    item.is_a?(Hash) ? item['text'] || item[:text] : item
  end

  def outline_list_item(item, show_counts: false)
    text = outcome_item_text(item)
    count = item.is_a?(Hash) ? item['count'] || item[:count] : nil

    body = outline_text_to_html(text)

    if show_counts && !count.nil?
      body = content_tag(:div, class: 'topic-outcome-row') do
        concat content_tag(:span, body, class: 'topic-outcome-text')
        concat content_tag(:span, pluralize(count, 'question'), class: 'topic-count-pill')
      end
    end

    content_tag(:li, body)
  end
end
