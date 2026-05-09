# frozen_string_literal: true

require 'rails_helper'

# A11y guard rails for the Topic Detail v2 chrome.  We assert ARIA
# attributes manually rather than pulling in axe-core for v1 — see the
# plan §3 rationale.  Sub-57 adds richer audits.
RSpec.describe 'Topic detail v2 chrome — a11y (sub-53)', type: :system, js: true do
  let!(:topic) do
    t = create(:topic, name: 'A11y Topic',
                       epigraph_quote: 'Quote.', epigraph_attribution: 'Author')
    2.times do |i|
      m = create(:topic_module, topic: t, name: "Module #{i}", position: i)
      create(:learning_objective, topic: t, topic_module: m,
                                  category: 'Cat', category_order: 0, position: i)
    end
    t
  end

  before { visit topic_path(topic) }

  it 'wraps the module list in <nav aria-label="Topic outline">' do
    expect(page).to have_css('nav[aria-label="Topic outline"] ul.topic-detail__sidebar-list li')
  end

  it 'renders the skip link as the first focusable element pointing at #topic-detail-main' do
    expect(page).to have_css('a.topic-detail__skip-link[href="#topic-detail-main"]', visible: :all)
    expect(page).to have_css('main#topic-detail-main')
    # The skip link is the first focusable element inside the topic-detail
    # wrapper so keyboard users hit it before the sticky sidebar.  The
    # global app nav contributes its own focusable brand link earlier in
    # the document — that's intentional and out of this issue's scope.
    first_focus_class = page.evaluate_script(<<~JS)
      (() => {
        const wrapper = document.querySelector('.topic-detail-v2, body');
        // The skip link sits as a sibling of .topic-detail-v2 inside the
        // <main> element, so look in the same parent.
        const main = wrapper.closest('main') || document.querySelector('main') || document.body;
        const candidate = main.querySelector('a, button, [tabindex]');
        return candidate?.className || '';
      })()
    JS
    expect(first_focus_class).to include('topic-detail__skip-link')
  end

  it 'gives every toolbar button type="button" — no <a> masquerading and no <div onclick>' do
    toolbar_buttons = page.all('.topic-detail__toolbar button', visible: :all)
    expect(toolbar_buttons).not_to be_empty
    toolbar_buttons.each do |btn|
      expect(btn['type']).to eq('button'), "expected type='button' got #{btn['type'].inspect}"
    end
    expect(page).not_to have_css('.topic-detail__toolbar a[role="button"]')
    expect(page).not_to have_css('.topic-detail__toolbar div[onclick]')
  end

  it 'sets aria-current="location" on the active sidebar entry after click' do
    first = topic.topic_modules.first
    find("a[data-module-id='#{first.id}']").click
    expect(page).to have_css("a[data-module-id='#{first.id}'][aria-current='location']")
  end

  it 'renders the sidebar list as semantic <ul><li><a href="#mod-{id}">' do
    topic.topic_modules.each do |mod|
      expect(page).to have_css("nav[aria-label='Topic outline'] ul li a[href='#mod-#{mod.id}']")
    end
  end

  it 'has no inline style="outline:none" anywhere on focusable elements' do
    expect(page.html).not_to match(/style="[^"]*outline:\s*none/i)
  end
end
