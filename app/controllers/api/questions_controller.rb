module Api
  class QuestionsController < BaseController
    def destroy
      question = Question.find_by(id: params[:id])
      unless question
        render json: { error: "Question #{params[:id]} not found" }, status: :not_found
        return
      end

      Rails.logger.info "[API] destroy_question: id=#{question.id} topic_id=#{question.topic_id}"
      question.destroy!
      head :no_content
    end

    def bulk
      topic = Topic.find(params[:topic_id])
      raw_questions = Array(params[:questions])

      if raw_questions.length > 500
        render json: { error: "Too many questions (#{raw_questions.length}). Maximum is 500." }, status: :unprocessable_entity
        return
      end

      strict = ActiveModel::Type::Boolean.new.cast(params[:strict]) || false
      valid_module_ids = topic.topic_modules.pluck(:id).to_set

      created = 0
      errors = []

      ActiveRecord::Base.transaction do
        raw_questions.each_with_index do |raw, index|
          q = permit_question(raw)
          client_id = q.delete(:client_id)

          # Resolve source by name if source_name provided
          if q[:source_name].present? && q[:source_id].blank?
            source = Source.find_by(name: q[:source_name])
            if source
              q[:source_id] = source.id
            else
              errors << { index: index, client_id: client_id, message: "Source not found: #{q[:source_name]}" }
              raise ActiveRecord::Rollback if strict
              next
            end
          end
          q.delete(:source_name)

          # Validate topic_module_id belongs to topic
          if q[:topic_module_id].present? && !valid_module_ids.include?(q[:topic_module_id].to_i)
            errors << { index: index, client_id: client_id, message: "topic_module_id #{q[:topic_module_id]} does not belong to topic #{topic.id}" }
            raise ActiveRecord::Rollback if strict
            next
          end

          lo_ids = Array(q.delete(:learning_objective_ids)).map(&:to_i)

          question = topic.questions.build(q.except(:client_id))
          if question.save
            if lo_ids.any?
              lo_ids.each do |lo_id|
                question.question_learning_objectives.create(learning_objective_id: lo_id)
              end
            end
            backfill_composite_parts_to_ar(question)
            created += 1
          else
            errors << { index: index, client_id: client_id, message: question.errors.full_messages.join(', ') }
            raise ActiveRecord::Rollback if strict
          end
        end

        # If strict mode and there were errors, the transaction was already rolled back
        if strict && errors.any?
          created = 0
        end
      end

      Rails.logger.info "[API] bulk_questions: topic_id=#{topic.id} created=#{created} errors=#{errors.count}"

      render json: { created: created, errors: errors }, status: (errors.any? && created == 0 ? :unprocessable_entity : :ok)
    end

    private

    # Editor #11 — the OpenAPI request body still ships composite parts as
    # `options.parts` jsonb so existing API clients don't need to change.
    # AR is the new source of truth, so map the jsonb shape onto
    # QuestionPart rows immediately after the parent saves. Idempotent: if
    # parts were already created (e.g. a future client supplies them
    # directly), this is a no-op.
    def backfill_composite_parts_to_ar(question)
      return unless question.question_type == 'composite'
      return unless question.options.is_a?(Hash)
      return if question.question_parts.any?

      Array(question.options['parts']).each_with_index do |part, idx|
        next unless part.is_a?(Hash)

        attrs = {
          position:  idx + 1,
          stem:      part['stem'],
          marks:     (part['marks'].presence || 1).to_i,
          part_type: (part['type'].presence || 'written'),
          options:   (part['options'].is_a?(Hash) ? part['options'] : {})
        }
        attrs[:answer_label] = part['answer_label'] if part.key?('answer_label')
        attrs[:unit]         = part['unit']         if part.key?('unit')
        if part.key?('answer_size')
          attrs[:options] = (attrs[:options] || {}).merge('answer_size' => part['answer_size'])
        end

        question.question_parts.create!(attrs)
      end
    end

    SCALAR_FIELDS = %w[
      content answer points question_type answer_size bloom_level
      source_reference answer_label unit
      topic_module_id source_id source_name client_id
    ].freeze

    def permit_question(raw)
      q = {}.with_indifferent_access
      raw_h = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h

      SCALAR_FIELDS.each do |field|
        q[field] = raw_h[field] if raw_h.key?(field)
      end

      # options can be an array or a hash depending on question_type
      q[:options] = raw_h['options'] if raw_h.key?('options')

      # learning_objective_ids is always an array of integers
      q[:learning_objective_ids] = Array(raw_h['learning_objective_ids']) if raw_h.key?('learning_objective_ids')

      q
    end
  end
end
