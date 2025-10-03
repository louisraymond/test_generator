class ExamsController < ApplicationController
  def new
    @topics = Topic.order(:name)
  end

  def create
    topic_ids = Array(params[:topic_ids]).reject(&:blank?)
    question_count = params[:question_count].to_i
    title = params[:title].presence || 'Practice Exam'

    if topic_ids.empty? || question_count <= 0
      redirect_to new_exam_path, alert: 'Select at least one topic and specify a question count.'
      return
    end

    questions = Question.where(topic_id: topic_ids)
                        .order(Arel.sql('RANDOM()'))
                        .limit(question_count)

    if questions.empty?
      redirect_to new_exam_path, alert: 'No questions available for the selected topics.'
      return
    end

    @exam = Exam.create!(title: title)

    questions.each_with_index do |question, index|
      @exam.exam_questions.create!(question: question, position: index + 1)
    end

    redirect_to exam_path(@exam)
  end

  def show
    @exam = Exam.includes(exam_questions: :question).find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'exams/show', layout: 'pdf', formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true
        ).to_pdf
        send_data pdf, filename: "exam_#{@exam.id}.pdf", type: 'application/pdf'
      end
    end
  end

  def marking_scheme
    @exam = Exam.includes(exam_questions: :question).find(params[:id])

    respond_to do |format|
      format.pdf do
        html = render_to_string(template: 'exams/marking_scheme', layout: false, formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true
        ).to_pdf
        send_data pdf, filename: "marking_scheme_#{@exam.id}.pdf", type: 'application/pdf'
      end
    end
  end
end
