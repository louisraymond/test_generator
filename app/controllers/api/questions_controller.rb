module Api
  class QuestionsController < BaseController
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

    SCALAR_FIELDS = %w[
      content answer points question_type answer_size
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
