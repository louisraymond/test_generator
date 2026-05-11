module Api
  class ExamTemplatesController < BaseController
    class ValidationError < StandardError; end

    rescue_from ValidationError do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: e.message, errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    rescue_from ExamBuilder::Error do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def index
      templates = ExamTemplate.includes(:exam_sections).order(created_at: :desc)
      render json: templates.map { |t| summary_payload(t) }
    end

    def show
      template = ExamTemplate.includes(
        exam_sections: [:section_source_rules, :section_question_rules]
      ).find(params[:id])
      render json: full_payload(template)
    end

    def create
      attrs = exam_template_params
      validate_request!(attrs)

      template = nil
      ActiveRecord::Base.transaction do
        template = ExamTemplate.new(attrs)
        template.save!
      end

      template.reload
      render json: full_payload(template), status: :created
    end

    def generate
      template = ExamTemplate.find(params[:id])
      title = params[:title].presence
      exam = ExamBuilder.from_template(
        template_id: template.id,
        title: title,
        preserve_order: true
      )

      render json: {
        exam_id: exam.id,
        title: exam.title,
        question_count: exam.exam_questions.count,
        pdf_url: pdf_api_exam_path(exam),
        marking_scheme_url: marking_scheme_pdf_api_exam_path(exam),
        sections: template.exam_sections.order(:position).map { |s|
          { position: s.position, name: s.name, question_count: s.question_count }
        }
      }, status: :created
    end

    private

    def exam_template_params
      params.require(:exam_template).permit(
        :name,
        :description,
        :duration_minutes,
        :subject,
        :paper_number,
        :tier,
        :subtitle,
        :rubric,
        :centre_name,
        :principles_of_marking,
        :sections_have_letters,
        candidate_fields: [],
        grade_boundaries: {},
        exam_sections_attributes: [
          :id,
          :name,
          :position,
          :question_count,
          :duration_minutes,
          :min_points,
          :max_points,
          :letter,
          :_destroy,
          { question_type_filter: [] },
          { section_source_rules_attributes: %i[id source_type source_id weight question_count_override _destroy] },
          { section_question_rules_attributes: %i[id question_id rule_type repeat_count _destroy] }
        ]
      )
    end

    def validate_request!(attrs)
      sections = Array(attrs[:exam_sections_attributes])
      sections.each do |section|
        type_filter = Array(section[:question_type_filter]).reject(&:blank?)

        Array(section[:section_question_rules_attributes]).each do |rule|
          next if rule[:_destroy].present?
          next unless rule[:rule_type] == 'force_include'

          qid = rule[:question_id]
          raise ValidationError, "Question #{qid} not found" unless qid.present?

          q = Question.find_by(id: qid)
          raise ValidationError, "Question #{qid} not found" unless q

          next if type_filter.empty?
          next if type_filter.include?(q.question_type.to_s)

          raise ValidationError,
                "Section '#{section[:name]}' force_includes question #{qid} of type " \
                "'#{q.question_type}', which is not in question_type_filter " \
                "#{type_filter.inspect}."
        end
      end
    end

    def summary_payload(template)
      {
        id: template.id,
        name: template.name,
        description: template.description,
        total_questions: template.total_questions,
        total_duration: template.total_duration,
        sections_count: template.exam_sections.size,
        use_count: template.use_count,
        created_at: template.created_at,
        updated_at: template.updated_at
      }
    end

    def full_payload(template)
      {
        id: template.id,
        name: template.name,
        description: template.description,
        duration_minutes: template.duration_minutes,
        tier: template.tier,
        subject: template.subject,
        paper_number: template.paper_number,
        total_questions: template.total_questions,
        total_duration: template.total_duration,
        use_count: template.use_count,
        created_at: template.created_at,
        updated_at: template.updated_at,
        exam_sections: template.exam_sections.order(:position).map { |section|
          {
            id: section.id,
            name: section.name,
            position: section.position,
            question_count: section.question_count,
            duration_minutes: section.duration_minutes,
            min_points: section.min_points,
            max_points: section.max_points,
            letter: section.letter,
            question_type_filter: section.question_type_filter || [],
            section_source_rules: section.section_source_rules.map { |r|
              {
                id: r.id,
                source_type: r.source_type,
                source_id: r.source_id,
                weight: r.weight,
                question_count_override: r.question_count_override
              }
            },
            section_question_rules: section.section_question_rules.order(:id).map { |r|
              {
                id: r.id,
                question_id: r.question_id,
                rule_type: r.rule_type,
                repeat_count: r.repeat_count
              }
            }
          }
        }
      }
    end
  end
end
