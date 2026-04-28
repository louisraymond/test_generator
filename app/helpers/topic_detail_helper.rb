# frozen_string_literal: true

module TopicDetailHelper
  # === sub-56: search/views ===

  # Returns [[category_name, [{lo:, module_idx:}, ...]], ...] sorted by category name
  # (case-insensitive). Each row is tagged with its source-module index (1-based,
  # matching the M01/M02 display tag in the categories view).
  def topic_outcomes_grouped_by_category(topic)
    module_idx_by_id = topic.topic_modules.each_with_index.to_h { |m, i| [m.id, i + 1] }

    topic.learning_objectives
         .group_by(&:category)
         .sort_by { |cat, _los| cat.to_s.downcase }
         .map do |cat, los|
           rows = los.sort_by { |lo| [lo.category_order.to_i, lo.position.to_i, lo.id] }
                     .map { |lo| { lo: lo, module_idx: module_idx_by_id[lo.topic_module_id] || 0 } }
           [cat, rows]
         end
  end

  # Returns [{lo:, module_idx:, topic_order:}, ...] sorted by `sort:`.
  # Valid sorts: :topic_order (default), :nq_desc, :nq_asc, :alpha.
  # `topic_order` is the index of the LO in the topic's default scope, which is
  # already ordered by (category_order, position, id) on the model.
  def topic_outcomes_flat(topic, sort: :topic_order)
    module_idx_by_id = topic.topic_modules.each_with_index.to_h { |m, i| [m.id, i + 1] }

    base = topic.learning_objectives.each_with_index.map do |lo, i|
      { lo: lo, module_idx: module_idx_by_id[lo.topic_module_id] || 0, topic_order: i }
    end

    case sort
    when :nq_desc then base.sort_by { |r| -r[:lo].questions.size }
    when :nq_asc  then base.sort_by { |r| r[:lo].questions.size }
    when :alpha   then base.sort_by { |r| r[:lo].description.to_s.downcase }
    else               base
    end
  end

  # === /sub-56 ===
end
