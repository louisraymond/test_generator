class ExamBuilder
  class Error < StandardError; end
  class MissingTopicsError < Error; end
  class NotEnoughQuestionsError < Error; end
  class MissingSectionsError < Error; end

  # Builds an exam from a template.
  #
  # preserve_order: when true, force_include rules are inserted in rule-id
  # order (i.e., the order they were created via the API), the section-final
  # `shuffle` is skipped, and the generator raises if a section's force_include
  # count exceeds its question_count. Used by the API path; defaults to false
  # so the web UI keeps its existing shuffle behavior.
  def self.from_template(template_id:, title: nil, preserve_order: false)
    template = ExamTemplate.find(template_id)
    raise MissingSectionsError, 'Template has no sections.' if template.exam_sections.empty?

    title ||= "#{template.name} - #{Time.current.strftime('%Y-%m-%d')}"

    ActiveRecord::Base.transaction do
      duration = template.total_duration
      duration = nil unless duration.to_i.positive? # Exam validates > 0 or nil

      exam = Exam.create!(
        title: title,
        duration_minutes: duration,
        exam_template_id: template.id
      )

      position = 1

      template.exam_sections.order(:position).each do |section|
        questions = build_section_questions(section, preserve_order: preserve_order)

        questions.each do |question|
          exam.exam_questions.create!(
            question: question,
            position: position,
            section_number: section.position
          )
          position += 1
        end
      end

      template.increment_use_count!
      exam
    end
  end

  # Builds an exam using random selection within the given topics.
  # Params
  # - topic_ids: Array of topic IDs
  # - count: requested number of questions
  # - title: exam title (default 'Practice Exam')
  # - strict: when true, raises if available < requested; when false, uses all available
  # - types: optional array of allowed question_type strings
  # - topic_weights: optional hash of topic_id => numeric weight (used to distribute count)
  # - duration_minutes: optional integer to set on the exam
  # - allow_repeats: when true, duplicates questions to reach requested count if needed
  def self.call(topic_ids:, count:, title: 'Practice Exam', strict: true, types: nil, topic_weights: nil, duration_minutes: nil, allow_repeats: false, topic_module_ids: nil, learning_objective_ids: nil)
    topic_ids = Array(topic_ids).reject(&:blank?)
    raise MissingTopicsError, 'Select at least one topic.' if topic_ids.empty?

    requested = count.to_i
    requested = 1 if requested < 1

    scope = Question.where(topic_id: topic_ids)
    scope = scope.where(topic_module_id: Array(topic_module_ids)) if topic_module_ids.present?
    if learning_objective_ids.present?
      scope = scope.joins(:question_learning_objectives)
                   .where(question_learning_objectives: { learning_objective_id: Array(learning_objective_ids) })
                   .distinct
    end
    scope = scope.where(question_type: Array(types)) if types.present?
    available = scope.count

    raise NotEnoughQuestionsError, 'No questions available for the selected topics.' if available.zero?
    if strict && !allow_repeats && available < requested
      raise NotEnoughQuestionsError, "Not enough questions: requested #{requested}, only #{available} available."
    end

    final_count = allow_repeats ? requested : [requested, available].min

    ActiveRecord::Base.transaction do
      exam = Exam.create!(title: title, duration_minutes: duration_minutes)

      selected = if topic_weights.present?
                   allocate_by_weights(scope, topic_ids, topic_weights, [final_count, available].min)
                 else
                   scope.order(Arel.sql('RANDOM()')).limit([final_count, available].min).to_a
                 end

      # If repeats are allowed and we still need more, pad by cycling
      if allow_repeats && selected.size < final_count
        needed = final_count - selected.size
        selected += selected.cycle.take(needed)
      end

      # Re-check strictness if repeats are not allowed
      if strict && !allow_repeats && selected.size < requested
        raise NotEnoughQuestionsError, "Not enough questions: requested #{requested}, only #{selected.size} available after filters."
      end

      selected.each_with_index do |question, index|
        exam.exam_questions.create!(question: question, position: index + 1)
      end

      exam
    end
  end

  # Allocate questions by per-topic weights and the filtered scope
  def self.allocate_by_weights(scope, topic_ids, weights, total_needed)
    usable = topic_ids.map(&:to_s).select { |tid| weights[tid].to_f > 0 }
    usable = topic_ids.map(&:to_s) if usable.empty?

    weight_values = usable.index_with { |tid| weights[tid].to_f.nonzero? || 1.0 }
    sum = weight_values.values.sum
    base_alloc = {}
    remainders = []

    # Count availability per topic for the given filters
    avail = scope.group(:topic_id).count.transform_keys(&:to_s)

    # Initial floor allocation
    weight_values.each do |tid, w|
      share = (total_needed * (w / sum))
      base = share.floor
      base_alloc[tid] = [base, avail.fetch(tid, 0)].min
      remainders << [tid, share - base]
    end

    assigned = base_alloc.values.sum
    remaining = [total_needed - assigned, 0].max

    # Distribute remaining by largest remainder and availability
    if remaining.positive?
      remainders.sort_by { |(_tid, rem)| -rem }.each do |(tid, _rem)|
        break if remaining <= 0
        next if base_alloc[tid] >= avail.fetch(tid, 0)
        base_alloc[tid] += 1
        remaining -= 1
      end
    end

    # Sample per-topic
    picked = []
    base_alloc.each do |tid, cnt|
      next if cnt <= 0
      picked.concat(scope.where(topic_id: tid).order(Arel.sql('RANDOM()')).limit(cnt).to_a)
    end

    picked
  end
  
  # Build questions for a specific section based on its rules.
  #
  # preserve_order: when true, force_includes are emitted in rule-id order,
  # the final shuffle is skipped, and over-pinning (forced > question_count)
  # raises. See ExamBuilder.from_template for context.
  def self.build_section_questions(section, preserve_order: false)
    forced_rules = section.section_question_rules.force_includes.order(:id).includes(:question)

    forced = []
    forced_rules.each do |rule|
      type_filter = section.question_types
      if type_filter.any? && rule.question.question_type.present? && !type_filter.include?(rule.question.question_type)
        raise Error,
              "Section '#{section.name}' force_includes question ##{rule.question_id} of " \
              "type '#{rule.question.question_type}', which is not allowed by question_type_filter " \
              "#{type_filter.inspect}."
      end
      rule.repeat_count.times { forced << rule.question }
    end

    if preserve_order && forced.size > section.question_count
      raise Error,
            "Section '#{section.name}' has #{forced.size} force_include rule(s) but " \
            "question_count is #{section.question_count}. Reduce force_includes or " \
            "raise question_count."
    end

    remaining_count = section.question_count - forced.size
    filled = []

    if remaining_count > 0
      available = section.available_questions

      filled = if section.section_source_rules.size > 1
                 select_by_source_weights(section, available, remaining_count)
               else
                 # Load to array first to avoid DISTINCT + RANDOM() conflict
                 available.to_a.shuffle.take(remaining_count)
               end
    end

    if preserve_order
      # Pinned questions stay in their declared order; only the random fill is shuffled.
      forced + filled.shuffle
    else
      (forced + filled).shuffle
    end
  end
  
  # Select questions using weighted distribution across source rules
  def self.select_by_source_weights(section, available_scope, needed)
    rules = section.section_source_rules.to_a
    total_weight = rules.sum(&:weight).to_f
    
    selected = []
    rules.each do |rule|
      # Calculate allocation for this source
      share = (needed * (rule.weight / total_weight)).round
      
      # Override with explicit count if specified
      allocation = rule.question_count_override || share
      allocation = [allocation, needed - selected.size].min
      
      next if allocation <= 0
      
      # Get questions from this specific source
      source_questions = case rule.source_type
      when 'Topic'
        available_scope.where(topic_id: rule.source_id)
      when 'TopicModule'
        available_scope.where(topic_module_id: rule.source_id)
      when 'LearningObjective'
        available_scope.joins(:question_learning_objectives)
                      .where(question_learning_objectives: { learning_objective_id: rule.source_id })
      end
      
      # Load to array first to avoid DISTINCT + RANDOM() conflict
      selected.concat(source_questions.to_a.shuffle.take(allocation))
    end
    
    selected
  end
end
