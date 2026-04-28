# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'topics/show.html.erb', type: :view do
  let!(:topic) do
    t = create(:topic, name: 'Thermal Physics')
    create(:topic_module, topic: t, name: 'Module A', position: 0)
    t.reload
  end

  before do
    assign(:topic, topic)
    assign(:exam_usage, nil)
  end

  context 'when v2 flag is on' do
    it 'renders the v2 wrapper with sidebar and main' do
      controller.request.path_parameters[:id] = topic.id
      params[:v2] = '1'
      render template: 'topics/show'
      expect(rendered).to have_css('.topic-detail-v2.premium-page-wrapper')
      expect(rendered).to have_css('aside.topic-detail-v2__sidebar')
      expect(rendered).to have_css('main#topic-detail-main')
      expect(rendered).to have_css('a.topic-detail__skip-link[href="#topic-detail-main"]')
      expect(rendered).to have_css('footer.topic-detail__footer-hint')
    end
  end

  context 'when v2 flag is off' do
    it 'renders the legacy chrome' do
      controller.request.path_parameters[:id] = topic.id
      render template: 'topics/show'
      expect(rendered).to have_css('.topic-detail.premium-page-wrapper')
      expect(rendered).not_to have_css('.topic-detail-v2')
    end
  end
end
