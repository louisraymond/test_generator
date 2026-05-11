# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'questions/_ranking', type: :view do
  def render_partial(options)
    question = build_stubbed(:question, question_type: 'ranking', options: options)
    render partial: 'questions/ranking', locals: { question: question }
  end

  it 'extracts the text from hash options instead of dumping the raw Ruby hash' do
    render_partial([
      { 'rank' => 1, 'text' => 'A well-formed HTML page' },
      { 'rank' => 2, 'text' => 'A semantically correct page' }
    ])

    expect(rendered).to include('A well-formed HTML page')
    expect(rendered).to include('A semantically correct page')
    # The bug rendered options as raw Ruby hash literals like {"rank"=>1, ...}.
    expect(rendered).not_to include('"rank"=&gt;')
    expect(rendered).not_to include('=&gt;')
  end

  it 'still renders plain-string options as-is (legacy shape)' do
    render_partial(['Alpha', 'Bravo'])

    expect(rendered).to include('Alpha')
    expect(rendered).to include('Bravo')
  end

  it 'accepts symbol-keyed hashes too' do
    render_partial([{ text: 'Sym one' }, { text: 'Sym two' }])

    expect(rendered).to include('Sym one')
    expect(rendered).to include('Sym two')
  end
end
