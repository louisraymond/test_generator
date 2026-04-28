# frozen_string_literal: true

require 'rails_helper'

# Regression guard for sub-53.  When the v2 feature flag is off, the topic
# detail page must render the legacy chrome unchanged so existing users
# (and the existing topic_detail_controller form flows) keep working.
RSpec.describe 'Topic detail — legacy path (sub-53 regression)', type: :system do
  let!(:topic) do
    create(:topic, name: 'Thermal Physics', epigraph_quote: 'Truth is...').tap do |t|
      m = create(:topic_module, topic: t, name: 'Module A', position: 0)
      create(:learning_objective, topic: t, topic_module: m, category: 'Heat',
             category_order: 0, position: 0, description: 'Explain heat')
    end
  end

  it 'renders the legacy markup when v2 is off' do
    visit topic_path(topic)
    # Legacy chrome markers — these must still be on the page.
    expect(page).to have_css('.topic-detail.premium-page-wrapper')
    expect(page).to have_css('.topic-detail__back')
    expect(page).to have_css('.modules-grid .module-card')
    # V2 wrapper class must be absent.
    expect(page).not_to have_css('.topic-detail-v2')
    expect(page).not_to have_css('.topic-detail-v2__sidebar')
  end
end
