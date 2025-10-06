module Api
  class QuestionsController < BaseController
    def create
      learning_objective = LearningObjective.find(params[:learning_objective_id])
      topic = learning_objective.topic

      question = topic.questions.new(question_params)
      question.question_type ||= 'written'
      question.points = params[:points].presence || 1

      if question.save
        QuestionLearningObjective.create!(question: question, learning_objective: learning_objective)
        render json: { message: 'Question created successfully!' }, status: :created
      else
        render json: { error: question.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end

    private

    def question_params
      params.permit(:content, :answer, :question_type, :answer_size, :source_id, :source_reference, :answer_label, :unit)
    end
  end
end
