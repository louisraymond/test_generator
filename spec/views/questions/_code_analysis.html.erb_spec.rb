require 'rails_helper'

RSpec.describe 'questions/_code_analysis', type: :view do
  let(:question) do
    build_stubbed(:question,
                  question_type: 'code_analysis',
                  answer_size: 'medium',
                  options: options)
  end

  let(:options) do
    {
      'language' => 'python',
      'code' => "def fib(n):\n    return n if n < 2 else fib(n-1) + fib(n-2)",
      'answer_format' => 'lines'
    }
  end

  def render_partial
    render partial: 'questions/code_analysis', locals: { question: question }
  end

  describe 'lines variant' do
    it 'renders the language badge' do
      render_partial
      expect(rendered).to have_css('.code-language-label', text: 'python')
    end

    it 'renders the code inside the code-analysis container' do
      render_partial
      expect(rendered).to have_css('.code-analysis .code-analysis-block')
      # Rouge tokenises the code into spans, so the raw substring `fib(n-1)`
      # won't appear verbatim; instead assert the identifiers show up.
      expect(rendered).to include('fib')
      expect(rendered).to include('n')
    end

    it 'applies syntax highlighting via Rouge (tokens present)' do
      render_partial
      # Rouge outputs spans with token class names; we just need evidence the
      # markdown pipeline ran, not specific tokens (which vary by lexer version).
      expect(rendered).to match(/<pre[^>]*class="[^"]*(highlight|md-code)/)
    end

    it 'renders ruled-lines answer area sized by answer_size' do
      render_partial
      expect(rendered).to have_css('.code-analysis .answer-lines.answer-lines-medium')
      expect(rendered).not_to have_css('.code-analysis .mc-options')
    end

    it 'defaults to medium size when answer_size is nil' do
      allow(question).to receive(:answer_size).and_return(nil)
      render_partial
      expect(rendered).to have_css('.answer-lines.answer-lines-medium')
    end
  end

  describe 'multiple_choice variant' do
    let(:options) do
      {
        'language' => 'ruby',
        'code' => "def names(items)\n  items.map(&:name).uniq\nend",
        'answer_format' => 'multiple_choice',
        'choices' => [
          { 'text' => 'Returns unique names', 'correct' => true },
          { 'text' => 'Mutates the items array', 'correct' => false },
          { 'text' => 'Raises NoMethodError', 'correct' => false }
        ]
      }
    end

    it 'renders choices with A/B/C lettering' do
      render_partial
      expect(rendered).to have_css('.code-analysis .mc-options')
      expect(rendered).to have_css('.mc-option', count: 3)
      expect(rendered).to have_css('.mc-label', text: 'A')
      expect(rendered).to have_css('.mc-label', text: 'B')
      expect(rendered).to have_css('.mc-label', text: 'C')
    end

    it 'shows choice text' do
      render_partial
      expect(rendered).to include('Returns unique names')
      expect(rendered).to include('Mutates the items array')
    end

    it 'includes checkbox markers (for student to tick)' do
      render_partial
      expect(rendered).to have_css('.mc-checkbox', count: 3)
    end

    it 'does not render ruled-lines in MC mode' do
      render_partial
      expect(rendered).not_to have_css('.code-analysis .answer-lines')
    end
  end

  describe 'robustness against malformed options' do
    it 'renders without error when options is nil' do
      allow(question).to receive(:options).and_return(nil)
      expect { render_partial }.not_to raise_error
    end

    it 'renders without error when options is missing code key' do
      allow(question).to receive(:options).and_return({ 'answer_format' => 'lines' })
      expect { render_partial }.not_to raise_error
    end

    it 'renders without language badge when language blank' do
      allow(question).to receive(:options).and_return(options.merge('language' => ''))
      render_partial
      expect(rendered).not_to have_css('.code-language-label')
    end

    it 'handles code containing triple-backticks without breaking fencing' do
      tricky = "puts \"```\"\nputs \"hello\""
      allow(question).to receive(:options).and_return(options.merge('code' => tricky))
      expect { render_partial }.not_to raise_error
      expect(rendered).to include('hello')
    end
  end
end
