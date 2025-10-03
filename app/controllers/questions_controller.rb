class QuestionsController < ApplicationController
  def types_preview
    @random_questions = Question.order(Arel.sql('RANDOM()')).limit(15)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'questions/types_preview', layout: 'pdf', formats: [:html])
        pdf = Grover.new(html, base_url: request.base_url).to_pdf
        send_data pdf, filename: 'preview.pdf', type: 'application/pdf'
      end
    end
  end
end
