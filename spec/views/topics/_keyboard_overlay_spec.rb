require 'rails_helper'

RSpec.describe 'topics/_keyboard_overlay', type: :view do
  subject(:rendered_html) do
    render partial: 'topics/keyboard_overlay'
    rendered
  end

  it 'renders the overlay hidden by default via aria-hidden' do
    expect(rendered_html).to have_css(
      '[data-topic-keyboard-target="overlay"][aria-hidden="true"]',
      visible: :all
    )
  end

  it 'declares dialog role, aria-modal, aria-labelledby' do
    expect(rendered_html).to have_css(
      '[role="dialog"][aria-modal="true"][aria-labelledby="shortcuts-title"]',
      visible: :all
    )
  end

  it 'includes the close button as a stimulus target' do
    expect(rendered_html).to have_css(
      'button[data-topic-keyboard-target="overlayClose"][aria-label="Close shortcuts overlay"]',
      visible: :all
    )
  end

  it 'renders all five shortcut groups: Navigation, Modules, Outcomes, Views & Heat-map, Misc' do
    %w[Navigation Modules Outcomes].each do |title|
      expect(rendered_html).to have_css('.kb-overlay__group-title', text: title, visible: :all)
    end
    expect(rendered_html).to have_css('.kb-overlay__group-title', text: 'Views & Heat-map', visible: :all)
    expect(rendered_html).to have_css('.kb-overlay__group-title', text: 'Misc', visible: :all)
  end

  it 'renders the visually-hidden discoverability button (a11y B.2)' do
    expect(rendered_html).to have_css(
      'button.visually-hidden',
      text: 'Open keyboard shortcuts overlay',
      visible: :all
    )
  end

  it 'renders the toast as a stimulus target, hidden by default' do
    expect(rendered_html).to have_css(
      '[data-topic-keyboard-target="toast"][hidden]',
      visible: :all
    )
  end

  it 'renders an aria-live polite announcer that is visually hidden' do
    expect(rendered_html).to have_css(
      '.visually-hidden[aria-live="polite"][data-topic-keyboard-target="ariaLive"]',
      visible: :all
    )
  end

  it 'lists the j / k / 1–9 / g g / / shortcuts under Navigation' do
    %w[j k 1–9].each do |key|
      expect(rendered_html).to have_css('kbd.kb-key', text: key, visible: :all)
    end
    expect(rendered_html).to have_css('kbd.kb-key', text: 'g g', visible: :all)
  end

  it 'lists space / o / c / e / n shortcuts under Modules' do
    %w[space o c e n].each do |key|
      expect(rendered_html).to have_css('kbd.kb-key', text: key, exact_text: key, visible: :all)
    end
  end

  it 'lists ? and Esc under Misc' do
    expect(rendered_html).to have_css('kbd.kb-key', text: '?', exact_text: '?', visible: :all)
    expect(rendered_html).to have_css('kbd.kb-key', text: 'Esc', exact_text: 'Esc', visible: :all)
  end
end
