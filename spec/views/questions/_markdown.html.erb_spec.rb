# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'questions/_markdown', type: :view do
  let(:question) do
    build_stubbed(:question,
                  question_type: 'markdown',
                  answer_size: answer_size,
                  content: 'Explain why entropy is a property of a distribution, not an outcome.')
  end

  def render_partial
    render partial: 'questions/markdown', locals: { question: question }
  end

  describe 'ruled writing space' do
    context 'when answer_size is nil' do
      let(:answer_size) { nil }

      it 'still renders an answer-lines div with the default short size' do
        render_partial
        expect(rendered).to have_css('.markdown-body .answer-lines.answer-lines-short')
      end
    end

    context 'when answer_size is explicitly set' do
      let(:answer_size) { 'long' }

      it 'renders with the requested size class' do
        render_partial
        expect(rendered).to have_css('.markdown-body .answer-lines.answer-lines-long')
      end
    end

    context 'when answer_size is medium' do
      let(:answer_size) { 'medium' }

      it 'renders with the medium size class' do
        render_partial
        expect(rendered).to have_css('.markdown-body .answer-lines.answer-lines-medium')
      end
    end
  end
end
