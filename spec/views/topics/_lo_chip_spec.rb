require 'rails_helper'

RSpec.describe 'topics/_lo_chip', type: :view do
  it 'renders a span with chip class and data attributes' do
    render partial: 'topics/lo_chip', locals: {
      q_count: 3,
      u_count: 7,
      chip_class: 'topic-detail__chip--b2',
      chip_text: '3q',
      chip_title: '3 questions, 7 exam uses',
      chip_label: '3 questions'
    }

    expect(rendered).to have_css('span.topic-detail__chip.topic-detail__chip--b2', text: '3q')
    expect(rendered).to have_css('span[data-questions="3"][data-usage="7"]')
    expect(rendered).to have_css('span[data-topic-module-target="chip"]')
    expect(rendered).to have_css('span[aria-label="3 questions"]')
    expect(rendered).to have_css('span[title="3 questions, 7 exam uses"]')
  end
end
