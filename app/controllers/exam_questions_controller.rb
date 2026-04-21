# frozen_string_literal: true

# Thin controller for Canvas-side interactions with a single exam question.
# Phase 6 renders the inspector rail; Phase 7 adds per-type editors.
class ExamQuestionsController < ApplicationController
  layout 'workspace'

  def rail
    @exam_question = ExamQuestion.includes(:question, :exam).find(params[:id])
    @question = @exam_question.question
    # Partial render bypasses the layout by design (the target is a
    # turbo-frame already inside a laid-out page, so no chrome is needed).
    render partial: 'exam_questions/rail',
           locals: { exam_question: @exam_question, question: @question }
  end
end
