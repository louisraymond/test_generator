module Api
  class ExamsController < BaseController
    def create
      topic_ids = Array(params[:topic_ids]).reject(&:blank?)
      count = params[:count].to_i
      title = params[:title].presence || 'Practice Exam'
      duration = params[:duration_minutes].presence&.to_i

      types = Array(params[:types]).reject(&:blank?)
      types &= Question::QUESTION_TYPES if types.present?

      strict = ActiveModel::Type::Boolean.new.cast(params.fetch(:strict, false)) || false

      module_ids = Array(params[:topic_module_ids]).reject(&:blank?)
      lo_ids = Array(params[:learning_objective_ids]).reject(&:blank?)

      exam = ExamBuilder.call(
        topic_ids: topic_ids,
        count: count,
        title: title,
        strict: strict,
        types: types.presence,
        duration_minutes: duration,
        topic_module_ids: module_ids.presence,
        learning_objective_ids: lo_ids.presence
      )

      render json: {
        id: exam.id,
        title: exam.title,
        question_count: exam.exam_questions.count,
        requested_count: count,
        pdf_url: pdf_api_exam_path(exam),
        marking_scheme_url: marking_scheme_pdf_api_exam_path(exam)
      }, status: :created
    rescue ExamBuilder::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def pdf
      @exam = Exam.includes(exam_questions: :question).find(params[:id])
      @font_size = params[:font_size]&.to_i || 14
      @question_spacing = params[:question_spacing]&.to_i || 18

      html = render_to_string(template: 'exams/show', layout: 'pdf', formats: [:html])
      pdf_data = PdfRenderer.render_to_pdf(html: html, base_url: request.base_url)
      send_data pdf_data, filename: "exam_#{@exam.id}.pdf", type: 'application/pdf'
    end

    def marking_scheme_pdf
      @exam = Exam.includes(exam_questions: :question).find(params[:id])

      html = render_to_string(template: 'exams/marking_scheme', layout: 'pdf', formats: [:html])
      pdf_data = PdfRenderer.render_to_pdf(html: html, base_url: request.base_url)
      send_data pdf_data, filename: "marking_scheme_#{@exam.id}.pdf", type: 'application/pdf'
    end
  end
end
