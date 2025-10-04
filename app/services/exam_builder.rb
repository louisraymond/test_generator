class ExamBuilder
  MAX_QUESTIONS = 50

  class Error < StandardError; end
  class MissingTopicsError < Error; end
  class NotEnoughQuestionsError < Error; end

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
  def self.call(topic_ids:, count:, title: 'Practice Exam', strict: true, types: nil, topic_weights: nil, duration_minutes: nil, allow_repeats: false)
    topic_ids = Array(topic_ids).reject(&:blank?)
    raise MissingTopicsError, 'Select at least one topic.' if topic_ids.empty?

    requested = count.to_i
    requested = 1 if requested < 1
    requested = MAX_QUESTIONS if requested > MAX_QUESTIONS

    scope = Question.where(topic_id: topic_ids)
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
end
