# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/_search_empty', type: :view do
  def render_partial
    render partial: 'topics/search_empty'
  end

  it 'renders hidden by default and is wired as the topic-search emptyState target' do
    render_partial
    expect(rendered).to have_css(
      'div.topic-detail__search-empty[data-topic-search-target="emptyState"][hidden]',
      visible: :all
    )
  end

  it 'embeds a slot for the unmatched query' do
    render_partial
    expect(rendered).to have_css('[data-search-empty-query]', visible: :all)
  end

  it 'has a Clear search button wired to topic-search#clear' do
    render_partial
    expect(rendered).to have_css(
      'button.topic-detail__search-empty__clear[data-action="click->topic-search#clear"]',
      text: /clear/i, visible: :all
    )
  end
end
