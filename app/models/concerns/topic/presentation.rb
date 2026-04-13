module Topic::Presentation
  extend ActiveSupport::Concern

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
end
